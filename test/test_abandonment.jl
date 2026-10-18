using ConcurrentSim
using ResumableFunctions
using Test

# An extension event whose only cleanup is recording that its subscription ended.
mutable struct SubscriptionEvent <: AbstractEvent
    bev::ConcurrentSim.BaseEvent
    releases::Int
    SubscriptionEvent(sim) = new(ConcurrentSim.BaseEvent(sim), 0)
end

ConcurrentSim.abandon_on_unobserved(::SubscriptionEvent) = true
function ConcurrentSim.on_abandon(ev::SubscriptionEvent)
    @test ev.bev.abandoned
    ev.releases += 1
end

@resumable function record_event(sim, ev, observations)
    result = @yield ev
    push!(observations, (now(sim), result))
end

@resumable function delayed_finish(sim, observations)
    @yield timeout(sim, 2)
    push!(observations, :finished)
    return :done
end

@testset "Only the last removed subscriber abandons an unfinished event" begin
    sim = Simulation()
    ev = SubscriptionEvent(sim)
    remove_callback(() -> nothing, ev)
    first = @callback identity(ev)
    second = @callback identity(ev)
    remove_callback(first, ev)
    remove_callback(first, ev)
    @test !ev.bev.abandoned
    @test ev.releases == 0
    remove_callback(second, ev)
    remove_callback(second, ev)
    @test ev.bev.abandoned
    @test ev.releases == 1
    @test isempty(ev.bev.callbacks)
    @test_throws ConcurrentSim.EventAbandoned ConcurrentSim.append_callback(identity, ev)
    @test_throws ConcurrentSim.EventAbandoned ConcurrentSim.schedule(ev)

    ordinary = Event(sim)
    callback = @callback identity(ordinary)
    remove_callback(callback, ordinary)
    remove_callback(callback, ordinary)
    @test !ordinary.bev.abandoned
    succeed(ordinary)
    run(sim, 1)
    @test state(ordinary) == ConcurrentSim.processed
end

@testset "A race releases losing inputs before its consumers run" begin
    sim = Simulation()
    waiting = SubscriptionEvent(sim)
    race = waiting | timeout(sim, 1)
    observed = Ref(false)
    ConcurrentSim.append_callback(race) do ev
        observed[] = waiting.bev.abandoned && waiting.releases == 1 && isempty(waiting.bev.callbacks)
    end
    run(sim, 2)
    @test observed[]
    @test !race.bev.abandoned
end

@testset "A shared losing wait retains its other subscriber" begin
    sim = Simulation()
    waiting = SubscriptionEvent(sim)
    early = waiting | timeout(sim, 1)
    late = waiting | timeout(sim, 3)
    early_results, late_results = [], []
    @process record_event(sim, early, early_results)
    @process record_event(sim, late, late_results)
    run(sim, 2)
    @test only(early_results)[1] == 1
    @test isempty(late_results)
    @test !waiting.bev.abandoned
    @test waiting.releases == 0
    ConcurrentSim.schedule(waiting; value=:arrival)
    run(sim, 4)
    at, result = only(late_results)
    @test at == 2
    @test result[waiting].value == :arrival
    @test waiting.releases == 0

    # A normally completed event remains yieldable after its callbacks ran.
    reused = []
    @process record_event(sim, waiting, reused)
    run(sim, 5)
    @test only(reused) == (4, :arrival)
end

@testset "Abandonment propagates through nested and duplicate inputs" begin
    for combine in ((&), (|), AllOf, AnyOf)
        sim = Simulation()
        a, b = SubscriptionEvent(sim), SubscriptionEvent(sim)
        branch = combine(a, b)
        race = branch | timeout(sim, 1)
        results = []
        @process record_event(sim, race, results)
        run(sim, 2)
        @test only(results)[1] == 1
        @test branch.bev.abandoned
        @test a.bev.abandoned && b.bev.abandoned
        @test a.releases == b.releases == 1
        @test isempty(a.bev.callbacks) && isempty(b.bev.callbacks)
        @test_throws ConcurrentSim.EventAbandoned ConcurrentSim.append_callback(identity, branch)
    end

    for combine in (AllOf, AnyOf)
        sim = Simulation()
        waiting = SubscriptionEvent(sim)
        branch = combine(waiting, waiting)
        @process record_event(sim, branch | timeout(sim, 1), [])
        run(sim, 2)
        @test branch.bev.abandoned
        @test waiting.releases == 1
        @test isempty(waiting.bev.callbacks)
    end
end

@testset "A shared input survives p & (p | timeout)" begin
    for arrival in (0.5, 2)
        sim = Simulation()
        waiting = SubscriptionEvent(sim)
        inner = waiting | timeout(sim, 1)
        outer = waiting & inner
        results = []
        @process record_event(sim, outer, results)
        ConcurrentSim.schedule(waiting, arrival; value=:arrival)
        run(sim, 1.5)
        @test isempty(results) == (arrival > 1.5)
        @test !waiting.bev.abandoned
        @test waiting.releases == 0
        run(sim, 3)
        at, result = only(results)
        @test at == arrival
        @test result[waiting].value == :arrival
        @test result[inner].state == ConcurrentSim.processed
        @test waiting.releases == 0
    end
end

@testset "Stale callbacks cannot restart an abandoned condition" begin
    sim = Simulation()
    trigger = Event(sim)
    waiting = SubscriptionEvent(sim)
    # The condition is abandoned by an earlier callback on the same input.
    ConcurrentSim.append_callback(trigger) do ev
        remove_callback(subscriber, branch)
    end
    branch = trigger | waiting
    subscriber = @callback identity(branch)
    succeed(trigger)
    run(sim, 1)
    @test branch.bev.abandoned
    @test state(branch) == ConcurrentSim.idle
    @test isempty(sim.heap)
    @test waiting.releases == 1
end

@testset "Abandoned events reject reuse before and after draining" begin
    for composite in (false, true), timing in (:idle, :scheduled, :processed)
        sim = Simulation()
        waiting = SubscriptionEvent(sim)
        ev = composite ? waiting | Event(sim) : waiting
        if timing != :idle
            ConcurrentSim.schedule(waiting, 1)
            composite && ConcurrentSim.step(sim) # Schedule the condition without processing it.
        end
        subscriber = @callback identity(ev)
        remove_callback(subscriber, ev)
        timing == :processed && run(sim, 2)
        @test ev.bev.abandoned
        @test_throws ConcurrentSim.EventAbandoned ConcurrentSim.append_callback(identity, ev)
        @test_throws ConcurrentSim.EventAbandoned ConcurrentSim.schedule(ev)
        @test_throws ConcurrentSim.EventAbandoned AnyOf(Event(sim), ev)
        @process record_event(sim, ev, [])
        @test_throws ConcurrentSim.EventAbandoned run(sim, 3)
    end
end

@testset "Invalid operator inputs do not leave subscriptions behind" begin
    sim = Simulation()
    abandoned = SubscriptionEvent(sim)
    subscriber = @callback identity(abandoned)
    remove_callback(subscriber, abandoned)
    completed = timeout(sim)
    run(sim, 1)
    for (invalid, exception) in ((abandoned, ConcurrentSim.EventAbandoned), (completed, ConcurrentSim.EventProcessed))
        fresh = SubscriptionEvent(sim)
        @test_throws exception AllOf(fresh, invalid)
        @test isempty(fresh.bev.callbacks)
        @test !fresh.bev.abandoned
        @test fresh.releases == 0
    end
end

@testset "Cleanup does not skip callbacks in the current dispatch" begin
    sim = Simulation()
    notifier = Event(sim)
    observed = Symbol[]
    first = ConcurrentSim.append_callback(notifier) do ev
        push!(observed, :first)
        remove_callback(first, ev)
    end
    ConcurrentSim.append_callback(ev -> push!(observed, :second), notifier)
    succeed(notifier)
    run(sim, 1)
    @test observed == [:first, :second]
end

@testset "An operator collects all inputs processed before its own turn" begin
    sim = Simulation()
    a = timeout(sim, 1; value=:a)
    b = timeout(sim, 1; value=:b)
    race = AnyOf(a, b)
    results = []
    @process record_event(sim, race, results)
    run(sim, 2)
    at, result = only(results)
    @test at == 1
    @test result[a].state == result[b].state == ConcurrentSim.processed
    @test (result[a].value, result[b].value) == (:a, :b)
end

@testset "Ordinary processes and resource requests continue after losing" begin
    sim = Simulation()
    completed = Symbol[]
    proc = @process delayed_finish(sim, completed)
    @process record_event(sim, proc | timeout(sim, 1), [])
    resource = Resource(sim)
    request(resource)
    queued_request = request(resource)
    @process record_event(sim, queued_request | timeout(sim, 1), [])
    run(sim, 1.5)
    @test isempty(completed)
    @test !proc.bev.abandoned
    @test !queued_request.bev.abandoned
    @test state(queued_request) == ConcurrentSim.idle
    release(resource)
    run(sim, 3)
    @test completed == [:finished]
    @test state(queued_request) == ConcurrentSim.processed
    @test islocked(resource)
    results = []
    @process record_event(sim, proc, results)
    run(sim, 4)
    @test only(results) == (3, :done)
end

@testset "A saved condition with only ordinary inputs still finishes" begin
    sim = Simulation()
    ordinary = Event(sim)
    clock = timeout(sim, 2; value=:clock)
    saved = AllOf(ordinary, clock)
    @process record_event(sim, saved | timeout(sim, 1), [])
    run(sim, 1.5)
    @test !saved.bev.abandoned
    succeed(ordinary; value=:arrival)
    run(sim, 3)
    @test state(saved) == ConcurrentSim.processed
    results = []
    @process record_event(sim, saved, results)
    run(sim, 4)
    at, result = only(results)
    @test at == 3
    @test result[ordinary].value == :arrival
    @test result[clock].value == :clock
end

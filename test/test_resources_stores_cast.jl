using ConcurrentSim
using ResumableFunctions
using Test

@resumable function producer(env, queue)
    for item in [1,2,3,4]
        @info "putting $item at time $(now(env))"
        put!(queue, item)
        @yield timeout(env, 2)
    end
end
@resumable function consumer(env, queue)
    @yield timeout(env, 5)
    while true
        t = @yield take!(queue)
        @test isa(t, Float64)
        @info "taking $(t) at time $(now(env))"
    end
end

function runsim(storeconstructor)
    sim = Simulation()
    queue = storeconstructor(sim)
    @process producer(sim, queue)
    @process consumer(sim, queue)
    run(sim, 30)
end

runsim(sim->DelayQueue{Float64}(sim, 10))
runsim(sim->QueueStore{Float64}(sim))
runsim(sim->Store{Float64}(sim))

# formatting was different in older versions
VERSION >= v"1.8" && @test_throws "MethodError: Cannot `convert`" runsim(sim->Store{Symbol}(sim))

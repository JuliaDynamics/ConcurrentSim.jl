using ConcurrentSim
using ResumableFunctions

@resumable function producer(env, queue)
    for item in [:a,:b,:a,:c]
        @info "putting $item at time $(now(env))"
        put!(queue, item)
        @yield timeout(env, 2)
    end
end
@resumable function consumer(env, queue)
    @yield timeout(env, 5)
    while true
        t = @yield take!(queue)
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

runsim(sim->DelayQueue{Symbol}(sim, 10))
runsim(sim->QueueStore{Symbol}(sim))
runsim(sim->Store{Symbol}(sim))

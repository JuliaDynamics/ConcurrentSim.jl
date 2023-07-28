# Ross, Simulation 5th edition:
  
## A repair problem

### Source

Ross, Simulation 5th edition, Section 7.7, p. 124-126

### Description

A system needs $n$ working machines to be operational. To guard against machine breakdown, additional machines are kept available as spares. Whenever a machine breaks down it is immediately replaced by a spare and is itself sent to the repair facility, which consists of a single repairperson who repairs failed machines one at a time. Once a failed machine has been repaired it becomes available as a spare to be used when the need arises. All repair times are independent random variables having the common distribution function $G$. Each time a machine is put into use the amount of time it functions before breaking down is a random variable, independent of the past, having distribution function $F$.

The system is said to “crash” when a machine fails and no spares are available. Assuming that there are initially $n + s$ functional machines of which $n$ are put in use and $s$ are kept as spares, we are interested in simulating this system so as to approximate $E[T]$, where $T$ is the time at which the system crashes.

### Code

```jldoctest
using ResumableFunctions
using ConcurrentSim

using Distributions
using Random
using StableRNGs

const RUNS = 5
const N = 10
const S = 3
const SEED = 150
const LAMBDA = 100
const MU = 1

const rng = StableRNG(42) # setting a random seed for reproducibility
const F = Exponential(LAMBDA)
const G = Exponential(MU)

@resumable function machine(env::Environment, repair_facility::Resource, spares::Store{Process})
    while true
        try @yield timeout(env, Inf) catch end
        @yield timeout(env, rand(rng, F))
        get_spare = get(spares)
        @yield get_spare | timeout(env)
        if state(get_spare) != ConcurrentSim.idle 
            @yield interrupt(value(get_spare))
        else
            throw(StopSimulation("No more spares!"))
        end
        @yield lock(repair_facility)
        @yield timeout(env, rand(rng, G))
        @yield release(repair_facility)
        @yield put!(spares, active_process(env))
    end
end

@resumable function start_sim(env::Environment, repair_facility::Resource, spares::Store{Process})
    for i in 1:N
        proc = @process machine(env, repair_facility, spares)
        @yield interrupt(proc)
    end
    for i in 1:S
        proc = @process machine(env, repair_facility, spares)
        @yield put!(spares, proc) 
    end
end

function sim_repair()
    sim = Simulation()
    repair_facility = Resource(sim)
    spares = Store{Process}(sim)
    @process start_sim(sim, repair_facility, spares)
    msg = run(sim)
    stop_time = now(sim)
    println("At time $stop_time: $msg")
    stop_time
end

results = Float64[]
for i in 1:RUNS push!(results, sim_repair()) end
println("Average crash time: ", sum(results)/RUNS)

# output

At time 12715.718224958666: No more spares!
At time 37335.53567595007: No more spares!
At time 30844.62667837361: No more spares!
At time 1601.2524911974856: No more spares!
At time 824.1048708405848: No more spares!
Average crash time: 16664.247588264083
```
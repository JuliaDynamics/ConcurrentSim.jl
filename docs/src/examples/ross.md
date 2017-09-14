# Ross, Simulation 5th edition:
  
## A repair problem

### Source

Ross, Simulation 5th edition, Section 7.7, p. 124-126

### Description

A system needs $n$ working machines to be operational. To guard against machine breakdown, additional machines are kept available as spares. Whenever a machine breaks down it is immediately replaced by a spare and is itself sent to the repair facility, which consists of a single repairperson who repairs failed machines one at a time. Once a failed machine has been repaired it becomes available as a spare to be used when the need arises. All repair times are independent random variables having the common distribution function $G$. Each time a machine is put into use the amount of time it functions before breaking down is a random variable, independent of the past, having distribution function $F$.

The system is said to “crash” when a machine fails and no spares are available. Assuming that there are initially $n + s$ functional machines of which $n$ are put in use and $s$ are kept as spares, we are interested in simulating this system so as to approximate $E[T]$, where $T$ is the time at which the system crashes.

### Code

```jldoctest
using Distributions
using ResumableFunctions
using SimJulia

const RUNS = 5
const N = 10
const S = 3
const SEED = 150
const LAMBDA = 100
const MU = 1

srand(SEED)
const F = Exponential(LAMBDA)
const G = Exponential(MU)

@resumable function machine(sim::Simulation, repair_facility::Resource, spares::Store{Process})
    while true
        try
            @yield Timeout(sim, Inf)
        catch exc
        end
        @yield Timeout(sim, rand(F))
        get_spare = Get(spares)
        @yield get_spare | Timeout(sim, 0.0)
        state(get_spare) != SimJulia.idle ? interrupt(value(get_spare)) : throw(SimJulia.StopSimulation("No more spares!"))
        @yield Request(repair_facility)
        @yield Timeout(sim, rand(G))
        @yield Release(repair_facility)
        @yield Put(spares, active_process(sim))
    end
end

@resumable function start_sim(sim::Simulation, repair_facility::Resource, spares::Store{Process})
    procs = Process[]
    for i=1:N
        push!(procs, @process machine(sim, repair_facility, spares))
    end
    @yield Timeout(sim, 0.0)
    for proc in procs
        interrupt(proc)
    end
    for i=1:S
        @yield Put(spares, @process machine(sim, repair_facility, spares))
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
for i=1:RUNS
    push!(results, sim_repair())
end
println("Average crash time: ", sum(results)/RUNS)

# output

At time 5573.772841846017: No more spares!
At time 1438.0294516073466: No more spares!
At time 7077.413276961621: No more spares!
At time 7286.490682742159: No more spares!
At time 6820.788098062124: No more spares!
Average crash time: 5639.298870243853
```
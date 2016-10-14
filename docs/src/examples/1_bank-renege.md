## Bank Renege

Covers:

- Resources
- Event operators

A counter with a random service time and customers who renege.

This example models a bank counter and customers arriving at random times. Each customer has a certain patience. It waits to get to the counter until she’s at the end of her tether. If she gets to the counter, she uses it for a while.

New customers are created by the source process every few time steps.

```@example
using SimJulia
using Distributions

const RANDOM_SEED = 150
const NEW_CUSTOMERS = 5  # Total number of customers
const INTERVAL_CUSTOMERS = 10.0  # Generate new customers roughly every x seconds
const MIN_PATIENCE = 1.0  # Min. customer patience
const MAX_PATIENCE = 3.0  # Max. customer patience

function source(sim::Simulation, number::Int, interval::Float64, counter::Resource)
  d = Exponential(interval)
  for i in 1:number
    Process(customer, sim, "Customer$i", counter, 12.0)
    yield(timeout(sim, rand(d)))
  end
end

function customer(sim::Simulation, name::String, counter::Resource, time_in_bank::Float64)
  arrive = now(sim)
  println("$arrive $name: Here I am")
  request(counter) do req
    patience = rand(Uniform(MIN_PATIENCE, MAX_PATIENCE))
    result = yield(req | timeout(sim, patience))
    wait = now(sim) - arrive
    if state(result[req]) == SimJulia.processed
      println("$(now(sim)) $name: Waited $wait")
      yield(timeout(sim, rand(Exponential(time_in_bank))))
      println("$(now(sim)) $name: Finished")
    else
      println("$(now(sim)) $name: RENEGED after $wait")
    end
  end
end

# Setup and start the simulation
println("Bank renege")
srand(RANDOM_SEED)
sim = Simulation()

# Start processes and run
counter = Resource(sim, 1)
Process(source, sim, NEW_CUSTOMERS, INTERVAL_CUSTOMERS, counter)
run(sim)
```

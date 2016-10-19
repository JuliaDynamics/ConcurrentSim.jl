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
    Process(customer, sim, "Customer $i", counter, 12.0)
    yield(Timeout(sim, rand(d)))
  end
end

function customer(sim::Simulation, name::String, counter::Resource, time_in_bank::Float64)
  arrive = now(sim)
  println("$arrive $name: Here I am")
  Request(counter) do req
    patience = rand(Uniform(MIN_PATIENCE, MAX_PATIENCE))
    yield(req | Timeout(sim, patience))
    wait = now(sim) - arrive
    if state(req) == SimJulia.triggered
      println("$(now(sim)) $name: Waited $wait")
      yield(Timeout(sim, rand(Exponential(time_in_bank))))
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

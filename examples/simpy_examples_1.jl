using SimJulia
using Distributions

const RANDOM_SEED = 150
const NEW_CUSTOMERS = 5  # Total number of customers
const INTERVAL_CUSTOMERS = 10.0  # Generate new customers roughly every x seconds
const MIN_PATIENCE = 1.0  # Min. customer patience
const MAX_PATIENCE = 3.0  # Max. customer patience

function source(env::Environment, number::Int64, interval::Float64, counter::Resource)
  d = Exponential(interval)
  for i in 1:number
    Process(env, customer, "Customer$i", counter, 12.0)
    yield(Timeout(env, rand(d)))
  end
end

function customer(env::Environment, name::ASCIIString, counter::Resource, time_in_bank::Float64)
  arrive = now(env)
  println("$arrive $name: Here I am")
  req = Request(counter)
  patience = rand(Uniform(MIN_PATIENCE, MAX_PATIENCE))
  result = yield(req | Timeout(env, patience))
  wait = now(env) - arrive
  if in(req, keys(result))
    println("$(now(env)) $name: Waited $wait")
    yield(Timeout(env, rand(Exponential(time_in_bank))))
    println("$(now(env)) $name: Finished")
    yield(Release(counter))
  else
    println("$(now(env)) $name: RENEGED after $wait")
    cancel(counter, req)
  end
end

# Setup and start the simulation
println("Bank renege")
srand(RANDOM_SEED)
env = Environment()

# Start processes and run
counter = Resource(env, 1)
Process(env, source, NEW_CUSTOMERS, INTERVAL_CUSTOMERS, counter)
run(env)

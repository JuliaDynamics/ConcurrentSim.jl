using SimJulia
using Distributions

const RANDOM_SEED = 09011977
const NUM_MACHINES = 2  # Number of machines in the carwash
const WASHTIME = 5.0    # Minutes it takes to clean a car
const T_BETWEEN = 5.0     # Create a car every ~5 minutes
const SIM_TIME = 30.0   # Simulation time in minutes

function wash(env::Environment)
  yield(Timeout(env, WASHTIME))
end

function car(env::Environment, cw::Resource)
  println("$(active_process(env)) arrives at the carwash at time $(round(now(env), 2)).")
  yield(Request(cw))
  println("$(active_process(env)) enters the carwash at time $(round(now(env), 2)).")
  yield(Process(env, wash))
  println("$(active_process(env)) leaves the carwash at time $(round(now(env), 2)).")
  yield(Release(cw))
end

function setup(env::Environment)
  cw = Resource(env, NUM_MACHINES)
  for i = 1:4
    Process(env, "Car $i", car, cw)
  end
  d = Uniform(T_BETWEEN-2.0, T_BETWEEN+2.0)
  i = 4
  while true
    yield(Timeout(env, rand(d)))
    Process(env, "Car $(i+=1)", car, cw)
  end
end

# Setup and start the simulation
println("Carwash")
srand(RANDOM_SEED)

# Create an environment and start the setup process
env = Environment()
Process(env, setup)

# Execute!
run(env, SIM_TIME)

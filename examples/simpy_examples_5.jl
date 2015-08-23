using SimJulia
using Distributions

const RANDOM_SEED = 14021986
const GAS_STATION_SIZE = 200                    # liters
const THRESHOLD = 10                            # Threshold for calling the tank truck (in %)
const FUEL_TANK_SIZE = 50                       # liters
const FUEL_TANK_LEVEL = DiscreteUniform(5, 25)  # Min/max levels of fuel tanks (in liters)
const REFUELING_SPEED = 2.0                     # liters / second
const TANK_TRUCK_TIME = 300.0                   # Seconds it takes the tank truck to arrive
const T_INTER = Uniform(30.0, 300.0)            # Create a car every (min, max) seconds
const SIM_TIME = 2000.0                         # Simulation time in seconds

function car(env::Environment, name::ASCIIString, gas_station::Resource, fuel_pump::Container{Int})
  fuel_tank_level = rand(FUEL_TANK_LEVEL)
  println("$name arriving at gas station at $(round(now(env), 2)) with $fuel_tank_level liters left in tank.")
  start = now(env)
  yield(Request(gas_station))
  liters_required = FUEL_TANK_SIZE - fuel_tank_level
  yield(Get(fuel_pump, liters_required))
  yield(Timeout(env, liters_required / REFUELING_SPEED))
  println("$name finished refueling in $(round((now(env)-start), 2)) seconds.")
  yield(Release(gas_station))
end

function gas_station_control(env::Environment, fuel_pump::Container{Int})
  while true
    if level(fuel_pump) / capacity(fuel_pump) * 100 < THRESHOLD
      println("Calling tank truck at $(round(now(env), 2)).")
      yield(Process(env, tank_truck, fuel_pump))
    end
    yield(Timeout(env, 10.0))  # Check every 10 seconds
  end
end

function tank_truck(env::Environment, fuel_pump::Container)
  yield(Timeout(env, TANK_TRUCK_TIME))
  println("Tank truck arriving at time $(round(now(env), 2)).")
  amount = capacity(fuel_pump) - level(fuel_pump)
  println("Tank truck refuelling $amount liters.")
  yield(Put(fuel_pump, amount))
end


function car_generator(env::Environment, gas_station::Resource, fuel_pump::Container{Int})
  i = 0
  while true
    yield(Timeout(env, rand(T_INTER)))
    Process(env, car, "Car $(i+=1)", gas_station, fuel_pump)
  end
end

# Setup and start the simulation
println("Gas Station refuelling")
srand(RANDOM_SEED)

# Create environment and start processes
env = Environment()
gas_station = Resource(env, 2)
fuel_pump = Container{Int64}(env, GAS_STATION_SIZE, GAS_STATION_SIZE)
Process(env, gas_station_control, fuel_pump)
Process(env, car_generator, gas_station, fuel_pump)

# Execute!
run(env, SIM_TIME)

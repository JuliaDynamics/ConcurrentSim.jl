Gas Station Refueling
---------------------

Covers:

  - Resources: :class:`Resource`
  - Resources: :class:`Container`
  - Waiting for other processes

This examples models a gas station and cars that arrive at the station for refueling.

The gas station has a limited number of fuel pumps and a fuel tank that is shared between the fuel pumps. The gas station is thus modeled as a :class:`Resource`. The shared fuel tank is modeled with a :class:`Container`.

Vehicles arriving at the gas station first request a fuel pump from the station. Once they acquire one, they try to take the desired amount of fuel from the fuel pump. They leave when they are done.

The gas stations fuel level is reqularly monitored by gas station control. When the level drops below a certain threshold, a tank truck is called to refuel the gas station itself.

.. code-block:: julia

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

The simulation’s output::

  Gas Station refuelling
  Car 1 arriving at gas station at 212.43 with 8 liters left in tank.
  Car 1 finished refueling in 21.0 seconds.
  Car 2 arriving at gas station at 482.13 with 22 liters left in tank.
  Car 2 finished refueling in 14.0 seconds.
  Car 3 arriving at gas station at 779.36 with 25 liters left in tank.
  Car 3 finished refueling in 12.5 seconds.
  Car 4 arriving at gas station at 964.75 with 17 liters left in tank.
  Car 4 finished refueling in 16.5 seconds.
  Car 5 arriving at gas station at 1011.92 with 9 liters left in tank.
  Car 5 finished refueling in 20.5 seconds.
  Car 6 arriving at gas station at 1121.88 with 20 liters left in tank.
  Calling tank truck at 1130.0.
  Car 6 finished refueling in 15.0 seconds.
  Car 7 arriving at gas station at 1361.4 with 25 liters left in tank.
  Tank truck arriving at time 1430.0.
  Tank truck refuelling 199 liters.
  Car 7 finished refueling in 81.1 seconds.
  Car 8 arriving at gas station at 1605.04 with 19 liters left in tank.
  Car 8 finished refueling in 15.5 seconds.
  Car 9 arriving at gas station at 1890.62 with 14 liters left in tank.
  Car 9 finished refueling in 18.0 seconds.

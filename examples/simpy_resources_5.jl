using SimJulia

type GasStation
  fuel_dispensers :: Resource
  gas_tank :: Container{Float64}
  function GasStation(env::Environment)
    gs = new()
    gs.fuel_dispensers = Resource(env, 2)
    gs.gas_tank = Container{Float64}(env, 1000.0, 100.0)
    Process(env, monitor_tank, gs)
    return gs
  end
end

function monitor_tank(env::Environment, gs::GasStation)
  while true
    if level(gs.gas_tank) < 100.0
      println("Calling tanker at $(now(env))")
      Process(env, tanker, gs)
    end
    yield(timeout(env, 15.0))
  end
end

function tanker(env::Environment, gs::GasStation)
  yield(timeout(env, 10.0))
  println("Tanker arriving at $(now(env))")
  amount = capacity(gs.gas_tank) - level(gs.gas_tank)
  yield(put(gs.gas_tank, amount))
end

function car(env::Environment, name::Int, gs::GasStation)
  println("Car $name arriving at $(now(env))")
  yield(request(gs.fuel_dispensers))
  println("Car $name starts refueling at $(now(env))")
  yield(get(gs.gas_tank, 40.0))
  yield(timeout(env, 5.0))
  yield(release(gs.fuel_dispensers))
  println("Car $name done refueling at $(now(env))")
end

function car_generator(env::Environment, gs::GasStation)
  for i = 0:3
    Process(env, car, i, gs)
    yield(timeout(env, 5.0))
  end
end

env = Environment()
gs = GasStation(env)
Process(env, car_generator, gs)
run(env, 55.0)
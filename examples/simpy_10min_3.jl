using SimJulia

function driver(env::Environment, car_proc::Process)
  yield(env, 3.0)
  interrupt(env, car_proc)
end

function car(env::Environment)
  while true
    println("Start parking and charging at $(now(env))")
    charge_duration = 5.0
    charge_proc = Process(env, charge, charge_duration)
    try
      yield(env, charge_proc)
    catch exc
      if isa(exc, Interrupt)
        println("Was interrupted. Hope, the battery is full enough ...")
      end
    end
    println("Start driving at $(now(env))")
    trip_duration = 2.0
    yield(env, trip_duration)
  end
end

function charge(env::Environment, duration::Float64)
  yield(env, duration)
end

env = Environment()
car_proc = Process(env, car)
Process(env, driver, car_proc)
run(env, 15.0)

using SimJulia

function driver(env::Environment, car_proc::Process)
  yield(Timeout(env, 3.0))
  yield(Interrupt(env, car_proc))
end

function car(env::Environment)
  while true
    println("Start parking and charging at $(now(env))")
    charge_duration = 5.0
    charge_proc = Process(env, charge, charge_duration)
    try
      yield(charge_proc)
    catch exc
      if isa(exc, InterruptException)
        println("Was interrupted. Hope, the battery is full enough ...")
      end
    end
    println("Start driving at $(now(env))")
    trip_duration = 2.0
    yield(Timeout(env, trip_duration))
  end
end

function charge(env::Environment, duration::Float64)
  yield(Timeout(env, duration))
end

env = Environment()
car_proc = Process(env, car)
Process(env, driver, car_proc)
run(env, 15.0)

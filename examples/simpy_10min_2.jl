using SimJulia

function car(env::Environment)
  while true
    println("Start parking and charging at $(now(env))")
    charge_duration = 5.0
    charge_proc = Process(env, charge, charge_duration)
    yield(env, charge_proc)

    println("Start driving at $(now(env))")
    trip_duration = 2.0
    yield(env, trip_duration)
  end
end

function charge(env::Environment, duration::Float64)
  yield(env, duration)
end

env = Environment()
Process(env, car)
run(env, 15.0)

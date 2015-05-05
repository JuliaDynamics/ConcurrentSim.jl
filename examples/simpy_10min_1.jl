using SimJulia

function car(env::Environment)
  while true
    println("Start parking at $(now(env))")
    parking_duration = 5.0
    yield(env, parking_duration)

    println("Start driving at $(now(env))")
    trip_duration = 2.0
    yield(env, trip_duration)
  end
end

env = Environment()
Process(env, car)
run(env, 15.0)

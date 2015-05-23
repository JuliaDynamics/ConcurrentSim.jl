using SimJulia

function drive(env::Environment)
  while true
    yield(timeout(env, 20.0*rand()+20.0))
    println("Start parking at $(now(env))")
    charging = Process(env, bat_ctrl)
    parking = timeout(env, 300.0*rand()+60.0)
    yield(charging & parking)
    println("Stop parking at $(now(env))")
  end
end

function bat_ctrl(env::Environment)
  println("Bat. ctrl. started at $(now(env))")
  yield(timeout(env, 60*rand()+30))
  println("Bat. ctrl. done at $(now(env))")
end

env = Environment()
Process(env, drive)
run(env, 310.0)
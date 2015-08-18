using SimJulia

function drive(env::Environment)
  while true
    yield(Timeout(env, 20.0*rand()+20.0))
    println("Start parking at $(now(env))")
    charging = Process(env, bat_ctrl)
    parking = Timeout(env, 60.0)
    yield(charging | parking)
    if !is_process_done(charging)
      yield(Interruption(charging, "Need to go!"))
    end
    println("Stop parking at $(now(env))")
  end
end

function bat_ctrl(env::Environment)
  println("Bat. ctrl. started at $(now(env))")
  try
    yield(Timeout(env, 60*rand()+30))
    println("Bat. ctrl. done at $(now(env))")
  catch exc
    println("Bat. ctrl. Interrupted at $(now(env)), msg: $(msg(exc))")
  end
end

env = Environment()
Process(env, drive)
run(env, 100.0)

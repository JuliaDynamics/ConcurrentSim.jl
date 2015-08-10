using SimJulia

type EV
  bat_ctrl_reactivate :: Event
  function EV(env::Environment)
    ev = new()
    ev.bat_ctrl_reactivate = Event(env)
    Process(env, drive, ev)
    Process(env, bat_ctrl, ev)
    return ev
  end
end

function drive(env::Environment, ev::EV)
  while true
    yield(Timeout(env, 20.0*rand()+20.0))
    println("Start parking at $(now(env))")
    succeed(ev.bat_ctrl_reactivate)
    ev.bat_ctrl_reactivate = Event(env)
    yield(Timeout(env, 300.0*rand()+60.0))
    println("Stop parking at $(now(env))")
  end
end

function bat_ctrl(env::Environment, ev::EV)
  while true
    println("Bat. ctrl. passivating at $(now(env))")
    yield(ev.bat_ctrl_reactivate)
    println("Bat. ctrl. reactivated at $(now(env))")
    yield(Timeout(env, 60*rand()+30))
  end
end

env = Environment()
ev = EV(env)
run(env, 150.0)

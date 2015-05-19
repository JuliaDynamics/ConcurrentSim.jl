type SimInterruptException <: Exception
  cause :: Process
  msg :: Any
  function SimInterruptException(cause::Process, msg::Any)
    inter = new()
    inter.cause = cause
    inter.msg = msg
    return inter
  end
end

function Interrupt(env::BaseEnvironment, proc::Process, msg::Any="")
  inter = Event(env)
  if !istaskdone(proc.task) && proc!=env.active_proc
    ev = Event(env)
    push!(ev.callbacks, proc.execute)
    schedule(ev, true, SimInterruptException(env.active_proc, msg))
    delete!(proc.target.callbacks, proc.execute)
  end
  schedule(inter)
  return inter
end

function show(io::IO, inter::SimInterruptException)
  print(io, "Interrupt caused by $(inter.cause): $(inter.msg)")
end

function cause(inter::SimInterruptException)
  return inter.cause
end

function msg(inter::SimInterruptException)
  return inter.msg
end

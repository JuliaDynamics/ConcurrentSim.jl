type SimInterruptException <: Exception
  cause :: Process
  msg :: ASCIIString
  function SimInterruptException(cause::Process, msg::ASCIIString)
    inter = new()
    inter.cause = cause
    inter.msg = msg
    return inter
  end
end

function interrupt(env::BaseEnvironment, proc::Process, cause::Process, msg::ASCIIString="")
  inter = Event(env)
  if !istaskdone(proc.task) && proc!=env.active_proc
    ev = Event(env)
    push!(ev.callbacks, proc.execute)
    schedule(ev, true, SimInterruptException(cause, msg))
    delete!(proc.target.callbacks, proc.execute)
  end
  schedule(inter)
  return inter
end

function interrupt(env::BaseEnvironment, proc::Process, msg::ASCIIString="")
  return interrupt(env, proc, env.active_proc, msg)
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

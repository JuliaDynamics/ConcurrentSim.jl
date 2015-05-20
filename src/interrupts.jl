type Interrupt <: Exception
  cause :: Process
  msg :: ASCIIString
  function Interrupt(cause::Process, msg::ASCIIString)
    inter = new()
    inter.cause = cause
    inter.msg = msg
    return inter
  end
end

function interrupt(env::BaseEnvironment, proc::Process, cause::Process, msg::ASCIIString="")
  if !istaskdone(proc.task) && proc!=env.active_proc
    ev = Event(env)
    push!(ev.callbacks, proc.execute)
    schedule(ev, true, Interrupt(cause, msg))
    delete!(proc.target.callbacks, proc.execute)
  end
  inter = Event(env)
  schedule(inter)
  return inter
end

function interrupt(env::BaseEnvironment, proc::Process, msg::ASCIIString="")
  return interrupt(env, proc, env.active_proc, msg)
end

function show(io::IO, inter::Interrupt)
  print(io, "Interrupt caused by $(inter.cause): $(inter.msg)")
end

function cause(inter::Interrupt)
  return inter.cause
end

function msg(inter::Interrupt)
  return inter.msg
end

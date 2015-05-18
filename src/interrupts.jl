type InterruptException <: Exception
  cause :: Process
  msg :: ASCIIString
  function InterruptException(cause::Process, msg::ASCIIString)
    inter = new()
    inter.cause = cause
    inter.msg = msg
    return inter
  end
end

function Interrupt(env::BaseEnvironment, proc::Process, msg::ASCIIString="")
  inter = Event(env)
  if !istaskdone(proc.task) && proc!=env.active_proc
    ev = Event(env)
    push!(ev.callbacks, proc.execute)
    schedule(ev, true, InterruptException(env.active_proc, msg))
    delete!(proc.target.callbacks, proc.execute)
  end
  schedule(inter)
  return inter
end

function show(io::IO, inter::InterruptException)
  print(io, "Interrupt caused by $(inter.cause): $(inter.msg)")
end

function cause(inter::InterruptException)
  return inter.cause
end

function msg(inter::InterruptException)
  return inter.msg
end

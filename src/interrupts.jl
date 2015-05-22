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

function interrupt(proc::Process, msg::ASCIIString="")
  env = environment(proc)
  if !istaskdone(proc.task) && proc!=env.active_proc
    ev = Event(env)
    push!(ev.callbacks, proc.execute)
    schedule(ev, true, Interrupt(active_process(env), msg))
    delete!(proc.target.callbacks, proc.execute)
  end
  return timeout(env, 0.0)
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

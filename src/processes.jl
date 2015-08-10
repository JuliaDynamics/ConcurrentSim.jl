type Process <: BaseEvent
  task :: Task
  target :: BaseEvent
  ev :: Event
  execute :: Function
  function Process(env::BaseEnvironment, task::Task)
    proc = new()
    proc.task = task
    proc.ev = Event(env)
    return proc
  end
end

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

function Process(env::BaseEnvironment, func::Function, args...)
  proc = Process(env, Task(()->func(env, args...)))
  proc.execute = (ev)->execute(env, ev, proc)
  ev = Event(env)
  push!(ev.callbacks, proc.execute)
  schedule(ev, true)
  proc.target = ev
  return proc
end

function show(io::IO, inter::InterruptException)
  print(io, "InterruptException caused by $(inter.cause): $(inter.msg)")
end

function show(io::IO, proc::Process)
  print(io, "Process $(proc.task)")
end

function triggered(proc::Process)
  return triggered(proc.ev)
end

function processed(proc::Process)
  return processed(proc.ev)
end

function set_active_process(env::BaseEnvironment, proc::Union(Nothing,Process))
  env.active_proc = proc
end

function active_process(env::BaseEnvironment)
  return env.active_proc
end

function value(proc::Process)
  return value(proc.ev)
end

function environment(proc::Process)
  return environment(proc.ev)
end

function cause(inter::InterruptException)
  return inter.cause
end

function msg(inter::InterruptException)
  return inter.msg
end

function append_callback(proc::Process, callback::Function, args...)
  push!(proc.ev.callbacks, (ev)->callback(ev, args...))
end

function execute(env::BaseEnvironment, ev::Event, proc::Process)
  try
    set_active_process(env, proc)
    value = consume(proc.task, ev.value)
    set_active_process(env, nothing)
    if istaskdone(proc.task)
      schedule(proc.ev, value)
    end
  catch exc
    set_active_process(env, nothing)
    if !isempty(proc.ev.callbacks)
      schedule(proc.ev, exc)
    else
      rethrow(exc)
    end
  end
end

function yield(ev::Event)
  if processed(ev)
    throw(EventProcessed())
  end
  active_process(environment(ev)).target = ev
  push!(ev.callbacks, active_process(environment(ev)).execute)
  value = produce(ev)
  if isa(value, Exception)
    throw(value)
  end
  return value
end

function yield(proc::Process)
  return yield(proc.ev)
end

typealias Interrupt Timeout

function Interrupt(proc::Process, msg::ASCIIString="")
  env = environment(proc)
  if !istaskdone(proc.task) && proc!=active_process(env)
    ev = Event(env)
    push!(ev.callbacks, proc.execute)
    schedule(ev, true, InterruptException(active_process(env), msg))
    delete!(proc.target.callbacks, proc.execute)
  end
  return Timeout(env, 0.0)
end

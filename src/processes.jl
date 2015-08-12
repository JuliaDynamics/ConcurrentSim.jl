using Compat

type Process <: BaseEvent
  task :: Task
  target :: BaseEvent
  ev :: Event
  resume :: Function
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
  proc.resume = (ev)->execute(env, ev, proc)
  ev = Event(env)
  push!(ev.callbacks, proc.resume)
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

function done(proc::Process)
  return istaskdone(proc.task)
end

function processing_or_processed(proc::Process)
  return processing_or_processed(proc.ev)
end

function active_process(env::BaseEnvironment)
  return @compat get(env.active_proc)
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
  append_callback(proc.ev, callback, args...)
end

function execute(env::BaseEnvironment, ev::Event, proc::Process)
  try
    env.active_proc = @compat Nullable(proc)
    value = consume(proc.task, ev.value)
    env.active_proc = @compat Nullable{Process}()
    if istaskdone(proc.task)
      schedule(proc.ev, value)
    end
  catch exc
    env.active_proc = @compat Nullable{Process}()
    if !isempty(proc.ev.callbacks)
      fail(proc.ev, exc)
    else
      rethrow(exc)
    end
  end
end

function yield(ev::Event)
  if ev.state == EVENT_PROCESSED
    return ev.value
  end
  active_process(environment(ev)).target = ev
  push!(ev.callbacks, active_process(environment(ev)).resume)
  value = produce(ev)
  if isa(value, Exception)
    throw(value)
  end
  return value
end

function yield(proc::Process)
  return yield(proc.ev)
end

function Interrupt(proc::Process, msg::ASCIIString="")
  env = environment(proc)
  if !istaskdone(proc.task) && proc!=active_process(env)
    ev = Event(env)
    push!(ev.callbacks, proc.resume)
    schedule(ev, true, InterruptException(active_process(env), msg))
    delete!(proc.target.callbacks, proc.resume)
  end
  return Timeout(env, 0.0)
end

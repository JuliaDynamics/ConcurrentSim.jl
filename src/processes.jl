using Compat

type Process <: BaseEvent
  task :: Task
  target :: Event
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

function active_process(env::BaseEnvironment)
  return @compat get(env.active_proc)
end

function cause(inter::InterruptException)
  return inter.cause
end

function msg(inter::InterruptException)
  return inter.msg
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

function yield(ev::BaseEvent)
  ev = convert(Event, ev)
  if ev.state == EVENT_PROCESSED
    return ev.value
  end
  proc = active_process(ev.env)
  proc.target = ev
  push!(ev.callbacks, proc.resume)
  value = produce(ev)
  if isa(value, Exception)
    throw(value)
  end
  return value
end

function Interrupt(proc::Process, msg::ASCIIString="")
  env = proc.ev.env
  active_proc = active_process(env)
  if !istaskdone(proc.task) && !is(proc, active_proc)
    ev = Event(env)
    push!(ev.callbacks, proc.resume)
    schedule(ev, true, InterruptException(active_proc, msg))
    delete!(proc.target.callbacks, proc.resume)
  end
  return Timeout(env, 0.0)
end

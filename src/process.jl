typealias Interrupt Event

type Process
  task :: Task
  target :: Event
  resume :: Function
  ev :: Event
  function Process(sim::Simulation, func::Function, args...)
    proc = new()
    proc.task = Task(()->func(sim, proc, args...))
    proc.ev = Event()
    proc.resume = (sim::Simulation, ev::Event)->execute(sim, ev, proc)
    proc.target = Event(sim)
    append_callback(proc.target, proc.resume)
    return proc
  end
end

type InterruptException <: Exception
  cause :: Any
  function InterruptException(cause::Any)
    inter = new()
    inter.cause = cause
    return inter
  end
end

function execute(sim::Simulation, ev::Event, proc::Process)
  try
    value = consume(proc.task, ev.value)
    if istaskdone(proc.task)
      schedule(proc.ev, value)
    end
  catch exc
    if !isempty(proc.ev.callbacks)
      schedule(proc.ev, exc)
    else
      rethrow(exc)
    end
  end
end

function yield(proc::Process, target::Event) :: Any
  if target.state == processing
    return target.value
  end
  proc.target = target
  append_callback(target, proc.resume)
  value = produce(nothing)
  if isa(value, Exception)
    throw(value)
  end
  return value
end

function yield(proc::Process, target::Process) :: Any
  yield(proc, target.ev)
end

function Interrupt(sim::Simulation, proc::Process, cause::Any=nothing) :: Event
  if !istaskdone(proc.task)
    remove_callback(proc.target, proc.resume)
    inter = Event(sim, priority=true, value=InterruptException(cause))
    proc.target = inter
    append_callback(inter, proc.resume)
  end
  return Event(sim)
end

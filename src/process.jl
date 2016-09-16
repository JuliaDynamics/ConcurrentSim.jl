function Process(sim::Simulation, func::Function, args...)
  task = Task(()->func(sim, args...))
  target = timeout(sim)
  return Process(task, target)
end

function execute(sim::Simulation, ev::Event, proc::Process)
  try
    sim.active_proc = Nullable(proc)
    value = consume(proc.task, ev.value)
    sim.active_proc = Nullable{Process}()
    if istaskdone(proc.task)
      schedule(sim, proc.ev, value=value)
    end
  catch exc
    if !isempty(proc.ev.callbacks)
      schedule(sim, proc.ev, value=exc)
    else
      rethrow(exc)
    end
  end
end

function yield(sim::Simulation, target::Event) :: Any
  if target.state == processed
    return target.value
  end
  proc = get(sim.active_proc)
  proc.target = target
  proc.resume = append_callback(proc.target, execute, proc)
  value = produce(nothing)
  if isa(value, Exception)
    throw(value)
  end
  return value
end

function yield(sim::Simulation, target::Process) :: Any
  yield(sim, target.ev)
end

function interrupt(sim::Simulation, proc::Process, cause::Any=nothing) :: Event
  if !istaskdone(proc.task)
    remove_callback(proc.target, proc.resume)
    proc.target = timeout(sim, priority=true, value=InterruptException(cause))
    proc.resume = append_callback(proc.target, execute, proc)
  end
  return timeout(sim, priority=true)
end

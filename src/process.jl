type Process{E<:Environment} <: AbstractEvent
  bev :: BaseEvent{E}
  task :: Task
  target :: AbstractEvent
  resume :: Function
  function Process(func::Function, env::E, args::Any...)
    proc = new()
    proc.bev = BaseEvent(env)
    proc.task = Task(()->func(env, args...))
    proc.target = timeout(env)
    proc.resume = append_callback(execute, proc.target, proc)
    return proc
  end
end

function Process{E<:Environment}(func::Function, env::E, args::Any...) :: Process{E}
  Process{E}(func, env, args...)
end

function execute(ev::AbstractEvent, proc::Process)
  try
    env = environment(ev)
    set_active_process(env, proc)
    ret = consume(proc.task, value(ev))
    set_active_process(env)
    if istaskdone(proc.task)
      schedule(proc.bev, value=ret)
    end
  catch exc
    rethrow(exc)
  end
end

function yield(target::AbstractEvent) :: Any
  env = environment(target)
  proc = active_process(env)
  if state(target) == processed
    proc.target = timeout(env, value=value(target))
  else
    proc.target = target
  end
  proc.resume = append_callback(execute, proc.target, proc)
  ret = produce(nothing)
  if isa(ret, Exception)
    throw(ret)
  end
  return ret
end

immutable InterruptException <: Exception
  cause :: Any
end

function interrupt(proc::Process, cause::Any=nothing) :: Timeout
  env = environment(proc)
  if !istaskdone(proc.task)
    remove_callback(proc.resume, proc.target)
    proc.target = timeout(env, priority=true, value=InterruptException(cause))
    proc.resume = append_callback(execute, proc.target, proc)
  end
  timeout(env, priority=true)
end

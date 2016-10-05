type Initialize{E<:Environment} <: AbstractEvent
  bev :: BaseEvent{E}
  function Initialize(env::E)
    init = new()
    init.bev = BaseEvent(env)
    schedule(init.bev)
    return init
  end
end

function Initialize{E<:Environment}(env::E) :: Initialize{E}
  Initialize{E}(env)
end

type Process{E<:Environment} <: AbstractEvent
  bev :: BaseEvent{E}
  task :: Task
  target :: AbstractEvent
  resume :: Function
  function Process(func::Function, env::E, args::Any...)
    proc = new()
    proc.bev = BaseEvent(env)
    proc.task = Task(()->func(env, args...))
    proc.target = Initialize(env)
    proc.resume = append_callback(execute, proc.target, proc)
    return proc
  end
end

function Process{E<:Environment}(func::Function, env::E, args::Any...) :: Process{E}
  Process{E}(func, env, args...)
end

function execute(ev::AbstractEvent, proc::Process)
  try
    ev.bev.env.active_proc = Nullable(proc)
    value = consume(proc.task, ev.bev.value)
    ev.bev.env.active_proc = Nullable{Process}()
    if istaskdone(proc.task)
      schedule(proc.bev, value=value)
    end
  catch exc
    if !isempty(proc.bev.callbacks)
      schedule(proc.bev, value=exc)
    else
      rethrow(exc)
    end
  end
end

function yield(target::AbstractEvent) :: Any
  if target.bev.state == processed
    #throw(EventProcessed())
    return target.bev.value
  end
  proc = get(target.bev.env.active_proc)
  proc.target = target
  proc.resume = append_callback(execute, proc.target, proc)
  value = produce(nothing)
  if isa(value, Exception)
    throw(value)
  end
  return value
end

type InterruptException <: Exception
  cause :: Any
end

type Interruption{E<:Environment} <: AbstractEvent
  bev :: BaseEvent{E}
  function Interruption(env::E, cause::Any)
    inter = new()
    inter.bev = BaseEvent(env)
    schedule(inter.bev, priority=true, value=InterruptException(cause))
    return inter
  end
end

function Interruption{E<:Environment}(env::E, cause::Any=nothing) :: Interruption{E}
  Interruption{E}(env, cause)
end

type Interrupt{E<:Environment} <: AbstractEvent
  bev :: BaseEvent{E}
  function Interrupt(proc::Process{E}, cause::Any=nothing)
    if !istaskdone(proc.task)
      remove_callback(proc.resume, proc.target)
      proc.target = Interruption(proc.bev.env, cause)
      proc.resume = append_callback(execute, proc.target, proc)
    end
    inter = new()
    inter.bev = BaseEvent(proc.bev.env)
    schedule(inter.bev, priority=true)
    return inter
  end
end

function Interrupt{E<:Environment}(proc::Process{E}, cause::Any=nothing) :: Interrupt{E}
  Interrupt{E}(proc, cause)
end

"""
A `Process` is an abstraction for an event yielding function, i.e. a process function.

The process function can suspend its execution by yielding an instance of `AbstractEvent`. The `Environment` will take care of resuming the process function with the value of that event once it has happened. The exception of failed events is also thrown into the process function.

A `Process` is a subtype of `AbstractEvent`. It is triggered, once the process functions returns or raises an exception. The value of the process is the return value of the process function or the exception, respectively.

**Signature**:

Process{E<:Environment} <: AbstractEvent{E}

**Fields**:

- `bev :: BaseEvent{E}`
- `task :: Task`
- `target :: AbstractEvent{E}`
- `resume :: Function`

**Constructor**:

Process{E<:Environment}(func::Function, env::E, args::Any...) :: Process{E}
"""
type Process{E<:Environment} <: AbstractEvent{E}
  bev :: BaseEvent{E}
  task :: Task
  target :: AbstractEvent{E}
  resume :: Function
  function Process(func::Function, env::E, args::Any...)
    proc = new()
    proc.bev = BaseEvent(env)
    proc.task = Task(()->func(env, args...))
    proc.target = Timeout(env)
    proc.resume = append_callback(execute, proc.target, proc)
    return proc
  end
end

function Process{E<:Environment}(func::Function, env::E, args::Any...) :: Process{E}
  Process{E}(func, env, args...)
end

function execute{E<:Environment}(ev::AbstractEvent{E}, proc::Process{E})
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

"""
Passes the control flow back to the simulation. If the yielded event is triggered, the `Environment` will resume the function after this statement.

The return value is the value from the yielded event.

**Method**:

yield(target::AbstractEvent) :: Any
"""
function yield(target::AbstractEvent) :: Any
  env = environment(target)
  proc = active_process(env)
  if state(target) == triggered
    proc.target = Timeout(env, value=value(target))
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

immutable InterruptException{E<:Environment} <: Exception
  by :: Process{E}
  cause :: Any
end

function interrupt{E<:Environment}(proc::Process{E}, cause::Any=nothing)
  env = environment(proc)
  if !istaskdone(proc.task)
    remove_callback(proc.resume, proc.target)
    proc.target = Timeout(env, priority=true, value=InterruptException(proc, cause))
    proc.resume = append_callback(execute, proc.target, proc)
  end
end

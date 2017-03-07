"""
A `Coroutine` is an abstraction for an event yielding function, i.e. a process function.

The process function can suspend its execution by yielding an instance of `AbstractEvent`. The `Environment` will take care of resuming the process function with the value of that event once it has happened. The exception of failed events is also thrown into the process function.

A `Coroutine` is a subtype of `AbstractEvent`. It is triggered, once the process functions returns or raises an exception. The value of the process is the return value of the process function or the exception, respectively.

**Signature**:

Coroutine{E<:Environment} <: AbstractEvent{E}

**Fields**:

- bev :: BaseEvent{E}
- task :: Task
- target :: AbstractEvent{E}
- resume :: Function

**Constructor**:

Coroutine{E<:Environment}(func::Function, env::E, args::Any...)
"""
type Coroutine{E<:Environment} <: AbstractProcess{E}
  bev :: BaseEvent{E}
  fsm :: FiniteStateMachine
  target :: AbstractEvent{E}
  resume :: Function
  function Coroutine{E}(func::Function, env::E, args::Any...) where E<:Environment
    proc = new()
    proc.bev = BaseEvent(env)
    proc.fsm = func(env, args...)
    proc.target = Timeout(env)
    proc.resume = append_callback(execute, proc.target, proc)
    return proc
  end
end

function Coroutine{E<:Environment}(func::Function, env::E, args::Any...)
  Coroutine{E}(func, env, args...)
end

"""
Creates a `Coroutine` with process function `func` having a required argument `env`, i.e. an instance of a subtype of `Environment`, and a variable number of arguments `args...`.

**Signature**:

@Coroutine func(env, args...)
"""
macro Coroutine(ex)
  if ex.head == :call
    func = esc(ex.args[1])
    args = [esc(ex.args[n]) for n in 2:length(ex.args)]
    return :(Coroutine($(func), $(args...)))
  end
end

function execute{E<:Environment}(ev::AbstractEvent{E}, proc::Coroutine{E})
  try
    env = environment(ev)
    set_active_process(env, proc)
    target = proc.fsm(value(ev))
    if iscoroutinedone(proc.fsm)
      schedule(proc.bev, value=target)
    else
      if state(target) == triggered
        proc.target = Timeout(env, value=value(target))
      else
        proc.target = target
      end
      proc.resume = append_callback(execute, proc.target, proc)
    end
    set_active_process(env)
  catch exc
    rethrow(exc)
  end
end

function interrupt(proc::Coroutine, cause::Any=nothing)
  if !iscoroutinedone(proc.fsm)
    remove_callback(proc.resume, proc.target)
    proc.target = Timeout(environment(proc), priority=true, value=InterruptException(proc, cause))
    proc.resume = append_callback(execute, proc.target, proc)
  end
end

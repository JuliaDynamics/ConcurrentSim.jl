mutable struct Coroutine <: DiscreteProcess
  bev :: BaseEvent
  fsm :: FiniteStateMachine
  target :: AbstractEvent
  resume :: Function
  function Coroutine(func::Function, env::Environment, args::Any...)
    cor = new()
    cor.bev = BaseEvent(env)
    cor.fsm = func(env, args...)
    cor.target = Timeout(env)
    cor.resume = @callback execute(cor.target, cor)
    cor
  end
end

macro coroutine(expr)
  expr.head != :call && error("Expression is not a function call!")
  func = esc(expr.args[1])
  args = [esc(expr.args[n]) for n in 2:length(expr.args)]
  :(Coroutine($(func), $(args...)))
end

function execute(ev::AbstractEvent, proc::Coroutine)
  try
    env = environment(ev)
    set_active_process(env, proc)
    target = proc.fsm(value(ev))
    reset_active_process(env)
    if iscoroutinedone(proc.fsm)
      schedule(proc; value=target)
    else
      proc.target = state(target) == triggered ? Timeout(env; value=value(target)) : target
      proc.resume = @callback execute(proc.target, proc)
    end
  catch exc
    rethrow(exc)
  end
end

function interrupt(proc::Coroutine, cause::Any=nothing)
  if !iscoroutinedone(proc.fsm)
    remove_callback(proc.resume, proc.target)
    proc.target = Timeout(environment(proc); priority=typemax(Int8), value=InterruptException(proc, cause))
    proc.resume = @callback execute(proc.target, proc)
  end
end

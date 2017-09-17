mutable struct Process <: DiscreteProcess
  bev :: BaseEvent
  fsmi :: ResumableFunctions.FiniteStateMachineIterator
  target :: AbstractEvent
  resume :: Function
  function Process(func::Function, env::Environment, args::Any...)
    cor = new()
    cor.bev = BaseEvent(env)
    cor.fsmi = func(env, args...)
    cor.target = Timeout(env)
    cor.resume = @callback execute(cor.target, cor)
    cor
  end
end

macro process(expr)
  expr.head != :call && error("Expression is not a function call!")
  esc(:(Process($(expr.args...))))
end

function execute(ev::AbstractEvent, proc::Process)
  try
    env = environment(ev)
    set_active_process(env, proc)
    target = proc.fsmi(value(ev))
    reset_active_process(env)
    if done(proc.fsmi)
      schedule(proc; value=target)
    else
      proc.target = state(target) == processed ? Timeout(env; value=value(target)) : target
      proc.resume = @callback execute(proc.target, proc)
    end
  catch exc
    rethrow(exc)
  end
end

function interrupt(proc::Process, cause::Any=nothing)
  if !done(proc.fsmi)
    remove_callback(proc.resume, proc.target)
    proc.target = Timeout(environment(proc); priority=typemax(Int8), value=InterruptException(proc, cause))
    proc.resume = @callback execute(proc.target, proc)
  end
end

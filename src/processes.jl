type Process <: DiscreteProcess
  bev :: BaseEvent
  task :: Task
  target :: AbstractEvent
  resume :: Function
  function Process(func::Function, env::Environment, args::Any...)
    proc = new()
    proc.bev = BaseEvent(env)
    proc.task = @task func(env, args...)
    proc.target = Timeout(env)
    proc.resume = @callback execute(proc.target, proc)
    return proc
  end
end

macro process(expr)
  expr.head != :call && error("Expression is not a function call!")
  func = esc(expr.args[1])
  args = [esc(expr.args[n]) for n in 2:length(expr.args)]
  :(Process($(func), $(args...)))
end

function yield(target::AbstractEvent)
  env = environment(target)
  proc = active_process(env)
  proc.target = state(target) == triggered ? Timeout(env; value=value(target)) : target
  proc.resume = @callback execute(proc.target, proc)
  ret = SimJulia.produce(nothing)
  isa(ret, Exception) && throw(ret)
  return ret
end

function execute(ev::AbstractEvent, proc::Process)
  try
    env = environment(ev)
    set_active_process(env, proc)
    ret = SimJulia.consume(proc.task, value(ev))
    reset_active_process(env)
    istaskdone(proc.task) && schedule(proc; value=ret)
  catch exc
    rethrow(exc)
  end
end

function interrupt(proc::Process, cause::Any=nothing)
  if !istaskdone(proc.task)
    remove_callback(proc.resume, proc.target)
    proc.target = Timeout(environment(proc); priority=typemax(Int8), value=InterruptException(proc, cause))
    proc.resume = @callback execute(proc.target, proc)
  end
end

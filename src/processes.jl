using Compat

type Initialize <: AbstractEvent
  bev :: BaseEvent
  function Initialize(env::AbstractEnvironment, callback)
    init = new()
    init.bev = BaseEvent(env)
    push!(init.bev.callbacks, callback)
    schedule(init, true)
    return init
  end
end

type Process <: AbstractEvent
  name :: ASCIIString
  task :: Task
  target :: AbstractEvent
  bev :: BaseEvent
  resume :: Function
  function Process(env::AbstractEnvironment, name::ASCIIString, func::Function, args...)
    proc = new()
    proc.name = name
    proc.task = Task(()->func(env, args...))
    proc.bev = BaseEvent(env)
    proc.resume = (ev)->execute(env, ev, proc)
    proc.target = Initialize(env, proc.resume)
    return proc
  end
end

type Interrupt <: AbstractEvent
  bev :: BaseEvent
  function Interrupt(proc::Process, cause::Any=nothing)
    inter = new()
    inter.bev = BaseEvent(proc.bev.env)
    push!(inter.bev.callbacks, proc.resume)
    schedule(inter, true, InterruptException(cause))
    delete!(proc.target.bev.callbacks, proc.resume)
    return inter
  end
end

type Interruption <: AbstractEvent
  bev :: BaseEvent
  function Interruption(proc::Process, cause::Any=nothing)
    inter = new()
    env = proc.bev.env
    inter.bev = BaseEvent(env)
    active_proc = active_process(env)
    if !istaskdone(proc.task) && !is(proc, active_proc)
      Interrupt(proc, cause)
    end
    schedule(inter)
    return inter
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

function Process(env::AbstractEnvironment, func::Function, args...)
  name = "$func"
  proc = Process(env, name, func, args...)
  proc.name = "SimJulia.Process $(proc.bev.id): $func"
  return proc
end

function show(io::IO, proc::Process)
  print(io, proc.name)
end

function show(io::IO, inter::InterruptException)
  print(io, "InterruptException: $(inter.cause)")
end

function is_process_done(proc::Process)
  return istaskdone(proc.task)
end

function cause(inter::InterruptException)
  return inter.cause
end

function execute(env::AbstractEnvironment, ev::AbstractEvent, proc::Process)
  try
    env.active_proc = @compat Nullable(proc)
    value = consume(proc.task, ev.bev.value)
    env.active_proc = @compat Nullable{Process}()
    if istaskdone(proc.task)
      schedule(proc, value)
    end
  catch exc
    env.active_proc = @compat Nullable{Process}()
    if !isempty(proc.bev.callbacks)
      schedule(proc, exc)
    else
      rethrow(exc)
    end
  end
end

function yield(ev::AbstractEvent)
  if ev.bev.state == EVENT_PROCESSED
    return ev.bev.value
  end
  proc = active_process(ev.bev.env)
  proc.target = ev
  push!(ev.bev.callbacks, proc.resume)
  value = produce(nothing)
  if isa(value, Exception)
    throw(value)
  end
  return value
end

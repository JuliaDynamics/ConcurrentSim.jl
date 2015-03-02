using Base.Collections

type Environment
  now :: Float64
  heap :: PriorityQueue{Event, EventID}
  eid :: Uint16
  active_proc :: Process
  function Environment(initial_time::Float64=0.0)
    env = new()
    env.now = initial_time
    env.heap = PriorityQueue{Event, EventID}()
    env.eid = 0
    return env
  end
end

type EmptySchedule <: Exception end
type TaskDone <: Exception end

function schedule(env::Environment, ev::Event, priority::Bool, delay::Float64, value=nothing)
  env.eid += 1
  env.heap[ev] = EventID(env.now + delay, priority, env.eid)
  ev.value = value
  return ev
end

function schedule(env::Environment, ev::Event, priority::Bool, value=nothing)
  schedule(env, ev, priority, 0.0, value)
end

function schedule(env::Environment, ev::Event, delay::Float64, value=nothing)
  schedule(env, ev, false, delay, value)
end

function schedule(env::Environment, ev::Event, value=nothing)
  schedule(env, ev, false, 0.0, value)
end

function run(env::Environment)
  ev = Event()
  run(env, ev)
end

function run(env::Environment, at::Float64)
  ev = Event()
  schedule(env, ev, at)
  run(env, ev)
end

function run(env::Environment, until::Event)
  push!(until.callbacks, (stop_simulate, NoneEvent()))
  try
    while true
      step(env)
    end
  catch exc
    if !isa(exc, EmptySchedule)
      throw(exc)
    end
  end
end

function step(env::Environment)
  if isempty(env.heap)
    throw(EmptySchedule())
  end
  ev_id = peek(env.heap)[2]
  env.now = ev_id.time
  ev = dequeue!(env.heap)
  ev.id = ev_id.id
  while !isempty(ev.callbacks)
    callback, base_ev = pop!(ev.callbacks)
    if isa(base_ev, Process)
      callback(env, ev, base_ev)
    else
      callback(env, ev)
    end
  end
end

function stop_simulate(env::Environment, ev::Event)
  throw(EmptySchedule())
end

function timeout(env::Environment, delay::Float64)
  ev = Event()
  schedule(env, ev, delay, "timeout")
  return ev
end

function execute(env::Environment, ev::Event, proc::Process)
  if istaskdone(proc.task)
    throw(TaskDone())
  end
  env.active_proc = proc
  consume(proc.task, ev.value)
  if istaskdone(proc.task)
    schedule(env, proc.ev, "taskdone")
  end
end

function process(env::Environment, name::ASCIIString, func::Function, args...)
  proc = Process(name, Task(()->func(env, args...)))
  ev = Event()
  push!(ev.callbacks, (execute, proc))
  schedule(env, ev, "execute")
  proc.target = ev
  return proc
end

function yield(env::Environment, ev::Event)
  env.active_proc.target = ev
  push!(ev.callbacks, (execute, env.active_proc))
  value = produce(ev)
  if isa(value, Exception)
    throw(value)
  end
end

function interrupt(env::Environment, proc::Process)
  if !istaskdone(proc.task)
    ev = Event()
    push!(ev.callbacks, (execute, proc))
    schedule(env, ev, InterruptException())
    delete!(proc.target.callbacks, (execute, proc))
  end
end

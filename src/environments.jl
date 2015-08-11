using Compat

type Environment <: BaseEnvironment
  time :: Float64
  sched :: PriorityQueue{Event, EventKey}
  eid :: Uint16
  active_proc :: @compat Nullable{Process}
  function Environment(initial_time::Float64=0.0)
    env = new()
    env.time = initial_time
    if VERSION >= v"0.4-"
      env.sched = PriorityQueue(Event, EventKey)
    else
      env.sched = PriorityQueue{Event, EventKey}()
    end
    env.eid = 0
    env.active_proc = @compat Nullable{Process}()
    return env
  end
end

function step(env::Environment)
  if isempty(env.sched)
    throw(EmptySchedule())
  end
  (ev, key) = peek(env.sched)
  dequeue!(env.sched)
  env.time = key.time
  ev.state = EVENT_PROCESSED
  while !isempty(ev.callbacks)
    callback = pop!(ev.callbacks)
    callback(ev)
  end
end

function peek(env::Environment)
  time = 0.0
  if isempty(env.sched)
    time = Inf
  else
    (ev, key) = peek(env.sched)
    time = key.time
  end
  return time
end

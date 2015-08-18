using Compat

type Environment <: AbstractEnvironment
  time :: Float64
  sched :: PriorityQueue{AbstractEvent, EventKey}
  eid :: Uint16
  active_proc :: @compat Nullable{Process}
  function Environment(initial_time::Float64=0.0)
    env = new()
    env.time = initial_time
    if VERSION >= v"0.4-"
      env.sched = PriorityQueue(AbstractEvent, EventKey)
    else
      env.sched = PriorityQueue{AbstractEvent, EventKey}()
    end
    env.eid = 0
    env.active_proc = @compat Nullable{Process}()
    return env
  end
end


function now(env::Environment)
  return env.time
end

function step(env::Environment)
  if isempty(env.sched)
    throw(EmptySchedule())
  end
  (ev, key) = peek(env.sched)
  dequeue!(env.sched)
  env.time = key.time
  ev.bev.state = EVENT_PROCESSING
  while !isempty(ev.bev.callbacks)
    pop!(ev.bev.callbacks)(ev)
  end
  ev.bev.state = EVENT_PROCESSED
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

function active_process(env::Environment)
  return @compat get(env.active_proc)
end

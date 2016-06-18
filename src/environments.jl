using Compat

type Environment <: AbstractEnvironment
  time :: Float64
  sched :: PriorityQueue{BaseEvent, EventKey}
  eid :: Int
  seid :: Int
  active_proc :: @compat Nullable{Process}
  function Environment(initial_time::Float64=0.0)
    env = new()
    env.time = initial_time
    if VERSION >= v"0.4-"
      env.sched = PriorityQueue(BaseEvent, EventKey)
    else
      env.sched = PriorityQueue{BaseEvent, EventKey}()
    end
    env.eid = 0
    env.seid = 0
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
  (bev, key) = peek(env.sched)
  dequeue!(env.sched)
  env.time = key.time
  bev.state = EVENT_PROCESSING
  while !isempty(bev.callbacks)
    pop!(bev.callbacks)(key.ev)
  end
  bev.state = EVENT_PROCESSED
end

function peek(env::Environment)
  time = 0.0
  if isempty(env.sched)
    time = Inf
  else
    (bev, key) = peek(env.sched)
    time = key.time
  end
  return time
end

function active_process(env::Environment)
  return get(env.active_proc)
end

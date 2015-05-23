type Environment <: BaseEnvironment
  time :: Float64
  sched :: PriorityQueue{Event, EventKey}
  eid :: Uint16
  active_proc :: Union(Nothing,Process) # replace with Nullable{Process} when version 4 is stable
  function Environment(initial_time::Float64=0.0)
    env = new()
    env.time = initial_time
    if VERSION >= v"0.4-"
      env.sched = PriorityQueue(Event, EventKey)
    else
      env.sched = PriorityQueue{Event, EventKey}()
    end
    env.eid = 0
    env.active_proc = nothing
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
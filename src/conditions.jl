function Condition(env::BaseEnvironment, eval::Function, events::Vector{Event})
  cond = Event(env)
  if isempty(events)
    succeed(cond, condition_values(events))
  end
  for ev in events
    if ev.state >= EVENT_PROCESSING
      check(ev, cond, eval, events)
    else
      append_callback(ev, check, cond, eval, events)
    end
  end
  return cond
end

function AllOf(env::BaseEnvironment, events::Vector{Event})
  return Condition(env, eval_and, events)
end

function AnyOf(env::BaseEnvironment, events::Vector{Event})
  return Condition(env, eval_or, events)
end

function condition_values(events::Vector{Event})
  values = Dict{Event, Any}()
  for ev in events
    if ev.state >= EVENT_PROCESSING
      values[ev] = ev.value
    end
  end
  return values
end

function check(ev::Event, cond::Event, eval::Function, events::Vector{Event})
  if cond.state == EVENT_INITIAL
    if isa(ev.value, Exception)
      fail(cond, ev.value)
    elseif eval(events)
      succeed(cond, condition_values(events))
    end
  end
end

function eval_and(events::Vector{Event})
  return all(map((ev)->ev.state >= EVENT_PROCESSING, events))
end

function eval_or(events::Vector{Event})
  return any(map((ev)->ev.state >= EVENT_PROCESSING, events))
end

function (&)(ev1::BaseEvent, ev2::BaseEvent)
  events = [convert(Event, ev1), convert(Event, ev2)]
  return Condition(events[1].env, eval_and, events)
end

function (|)(ev1::BaseEvent, ev2::BaseEvent)
  events = [convert(Event, ev1), convert(Event, ev2)]
  return Condition(events[1].env, eval_or, events)
end

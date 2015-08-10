typealias Condition Event

function Condition(env::BaseEnvironment, eval::Function, events::Vector{BaseEvent})
  cond = Event(env)
  if isempty(events)
    succeed(cond, condition_values(events))
  end
  for ev in events
    if processed(ev)
      check(ev, cond, eval, events)
    else
      append_callback(ev, check, cond, eval, events)
    end
  end
  return cond
end

typealias AllOf Condition

function AllOf(env::BaseEnvironment, events::Vector{BaseEvent})
  return Condition(env, eval_and, events)
end

typealias AnyOf Condition

function AnyOf(env::BaseEnvironment, events::Vector{BaseEvent})
  return Condition(env, eval_or, events)
end

function condition_values(events::Vector{BaseEvent})
  values = Dict{BaseEvent, Any}()
  for ev in events
    if processed(ev)
      values[ev] = value(ev)
    end
  end
  return values
end

function check(ev::BaseEvent, cond::Condition, eval::Function, events::Vector{BaseEvent})
  if !triggered(cond) && !processed(cond)
    if isa(value(ev), Exception)
      fail(cond, value(ev))
    elseif eval(events)
      succeed(cond, condition_values(events))
    end
  end
end

function eval_and(events::Vector{BaseEvent})
  return all(map((ev)->processed(ev), events))
end

function eval_or(events::Vector{BaseEvent})
  return any(map((ev)->processed(ev), events))
end

function (&)(ev1::BaseEvent, ev2::BaseEvent)
  events = BaseEvent[ev1, ev2]
  return Condition(environment(ev1), eval_and, events)
end

function (|)(ev1::BaseEvent, ev2::BaseEvent)
  events = BaseEvent[ev1, ev2]
  return Condition(environment(ev1), eval_or, events)
end

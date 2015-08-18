const EVENT_INITIAL = 0
const EVENT_TRIGGERED = 1
const EVENT_PROCESSING = 2
const EVENT_PROCESSED = 3

type Event <: AbstractEvent
  bev :: BaseEvent
  function Event(env::AbstractEnvironment)
    ev = new()
    ev.bev = BaseEvent(env)
    return ev
  end
end

type Timeout <: AbstractEvent
  bev :: BaseEvent
  function Timeout(env::AbstractEnvironment, delay::Float64, value=nothing)
    timeout = new()
    timeout.bev = BaseEvent(env)
    schedule(timeout, delay, value)
    return timeout
  end
end

type EventOperator <: AbstractEvent
  events :: Vector{AbstractEvent}
  eval :: Function
  bev :: BaseEvent
  function EventOperator(env::AbstractEnvironment, eval::Function, ev::AbstractEvent, events...)
    oper = new()
    oper.bev = BaseEvent(env)
    oper.events = AbstractEvent[ev, events...]
    oper.eval = eval
    for ev in oper.events
      if ev.bev.state >= EVENT_PROCESSING
        check(ev, oper)
      else
        push!(ev.bev.callbacks, (ev)->check(ev, oper))
      end
    end
    return oper
  end
end

function EventOperator(eval::Function, ev::AbstractEvent, events...)
  return EventOperator(ev.bev.env, eval, ev, events...)
end

function AllOf(ev::AbstractEvent, events...)
  return EventOperator(eval_and, ev, events...)
end

function AnyOf(ev::AbstractEvent, events...)
  return EventOperator(eval_or, ev, events...)
end

function populate_value(oper::EventOperator, values::Dict{AbstractEvent, Any})
  for ev in oper.events
    if isa(ev, EventOperator)
      populate_value(ev, values)
    elseif ev.bev.state >= EVENT_PROCESSING
      values[ev] = ev.bev.value
    end
  end
end

function check(ev::AbstractEvent, oper::EventOperator)
  if oper.bev.state == EVENT_INITIAL
    if isa(ev.bev.value, Exception)
      schedule(oper, ev.bev.value)
    elseif oper.eval(oper.events)
      values = Dict{AbstractEvent, Any}()
      populate_value(oper, values)
      schedule(oper, values)
    end
  end
end

function eval_and(events::Vector{AbstractEvent})
  return all(map((ev)->ev.bev.state >= EVENT_PROCESSING, events))
end

function eval_or(events::Vector{AbstractEvent})
  return any(map((ev)->ev.bev.state >= EVENT_PROCESSING, events))
end

function (&)(ev1::AbstractEvent, ev2::AbstractEvent)
  return EventOperator(eval_and, ev1, ev2)
end

function (|)(ev1::AbstractEvent, ev2::AbstractEvent)
  return EventOperator(eval_or, ev1, ev2)
end

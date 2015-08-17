type EventOperator <: BaseEvent
  events :: Vector{BaseEvent}
  eval :: Function
  ev :: Event
  function EventOperator(env::BaseEnvironment, eval::Function, ev::BaseEvent, events...)
    oper = new()
    oper.ev = Event(env)
    oper.events = BaseEvent[ev, events...]
    oper.eval = eval
    for bev in oper.events
      ev = convert(Event, bev)
      if ev.state >= EVENT_PROCESSING
        check(ev, oper)
      else
        push!(ev.callbacks, (ev)->check(ev, oper))
      end
    end
    return oper
  end
end

function EventOperator(eval::Function, ev::BaseEvent, events...)
  return EventOperator(convert(Event, ev).env, eval, ev, events...)
end

function AllOf(ev::BaseEvent, events...)
  return EventOperator(eval_and, ev, events...)
end

function AnyOf(ev::BaseEvent, events...)
  return EventOperator(eval_or, ev, events...)
end

function populate_value(oper::EventOperator, values::Dict{BaseEvent, Any})
  for bev in oper.events
    ev = convert(Event, bev)
    if isa(bev, EventOperator)
      populate_value(bev, values)
    elseif ev.state >= EVENT_PROCESSING
      values[bev] = ev.value
    end
  end
end

function check(ev::Event, oper::EventOperator)
  if oper.ev.state == EVENT_INITIAL
    if isa(ev.value, Exception)
      schedule(oper.ev, ev.value)
    elseif oper.eval(oper.events)
      values = Dict{BaseEvent, Any}()
      populate_value(oper, values)
      schedule(oper.ev, values)
    end
  end
end

function eval_and(events::Vector{BaseEvent})
  return all(map((ev)->convert(Event, ev).state >= EVENT_PROCESSING, events))
end

function eval_or(events::Vector{BaseEvent})
  return any(map((ev)->convert(Event, ev).state >= EVENT_PROCESSING, events))
end

function (&)(ev1::BaseEvent, ev2::BaseEvent)
  return EventOperator(eval_and, ev1, ev2)
end

function (|)(ev1::BaseEvent, ev2::BaseEvent)
  return EventOperator(eval_or, ev1, ev2)
end

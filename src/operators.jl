type StateValue
  state :: EVENT_STATE
  value :: Any
  function StateValue(state::EVENT_STATE, value::Any=nothing)
    new(state, value)
  end
end

type Operator <: AbstractEvent
  bev :: BaseEvent
  eval :: Function
  function Operator(eval::Function, fev::AbstractEvent, events::AbstractEvent...)
    op = new()
    op.bev = BaseEvent(fev.bev.env)
    op.eval = eval
    event_state_values = Dict{BaseEvent, StateValue}()
    for ev in tuple(fev, events...)
      event_state_values[ev.bev] = StateValue(ev.bev.state)
      append_callback(check, ev, op, event_state_values)
    end
    return op
  end
end

function check(ev::AbstractEvent, op::Operator, event_state_values::Dict{BaseEvent, StateValue})
  if op.bev.state == idle
    if isa(ev.bev.value, Exception)
      schedule(op.bev, value=ev.bev.value)
    else
      event_state_values[ev.bev] = StateValue(ev.bev.state, ev.bev.value)
      if op.eval(collect(values(event_state_values)))
        schedule(op.bev, value=event_state_values)
      end
    end
  elseif op.bev.state == triggered
    if isa(ev.bev.value, Exception)
      schedule(op.bev, priority=true, value=ev.bev.value)
    else
      event_state_values[ev.bev] = StateValue(ev.bev.state, ev.bev.value)
    end
  end
end

function eval_and(state_values::Vector{StateValue})
  return all(map((sv)->sv.state == processed, state_values))
end

function eval_or(state_values::Vector{StateValue})
  return any(map((sv)->sv.state == processed, state_values))
end

function (&)(ev1::AbstractEvent, ev2::AbstractEvent)
  return Operator(eval_and, ev1, ev2)
end

function (|)(ev1::AbstractEvent, ev2::AbstractEvent)
  return Operator(eval_or, ev1, ev2)
end

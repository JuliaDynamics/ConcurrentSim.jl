struct StateValue
  state :: EVENT_STATE
  value :: Any
  function StateValue(state::EVENT_STATE, value::Any=nothing)
    new(state, value)
  end
end

struct Operator <: AbstractEvent
  bev :: BaseEvent
  eval :: Function
  function Operator(eval::Function, fev::AbstractEvent, events::AbstractEvent...)
    env = environment(fev)
    op = new(BaseEvent(env), eval)
    event_state_values = Dict{AbstractEvent, StateValue}()
    for ev in tuple(fev, events...)
      event_state_values[ev] = StateValue(state(ev))
      @callback check(ev, op, event_state_values)
    end
    op
  end
end

function check(ev::AbstractEvent, op::Operator, event_state_values::Dict{AbstractEvent, StateValue})
  val = value(ev)
  if state(op) == idle
    if isa(val, Exception)
      schedule(op; value=val)
    else
      event_state_values[ev] = StateValue(state(ev), val)
      op.eval(collect(values(event_state_values))) && schedule(op; value=event_state_values)
    end
  elseif state(op) == scheduled
    if isa(val, Exception)
      schedule(op; priority=typemax(Int8), value=val)
    else
      event_state_values[ev] = StateValue(state(ev), val)
    end
  end
end

function eval_and(state_values::Vector{StateValue})
  all(map((sv)->sv.state == triggered, state_values))
end

function eval_or(state_values::Vector{StateValue})
  any(map((sv)->sv.state == triggered, state_values))
end

function (&)(ev1::AbstractEvent, ev2::AbstractEvent)
  Operator(eval_and, ev1, ev2)
end

function (|)(ev1::AbstractEvent, ev2::AbstractEvent)
  Operator(eval_or, ev1, ev2)
end

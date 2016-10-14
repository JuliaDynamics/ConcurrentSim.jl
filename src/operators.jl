immutable StateValue
  state :: EVENT_STATE
  value :: Any
  function StateValue(state::EVENT_STATE, value::Any=nothing)
    new(state, value)
  end
end

function state(sv::StateValue) :: EVENT_STATE
  sv.state
end

type Operator{E<:Environment} <: AbstractEvent{E}
  bev :: BaseEvent
  eval :: Function
  function Operator(eval::Function, fev::AbstractEvent{E}, events::AbstractEvent{E}...)
    env = environment(fev)
    op = new(BaseEvent(env), eval)
    event_state_values = Dict{AbstractEvent{E}, StateValue}()
    for ev in tuple(fev, events...)
      event_state_values[ev] = StateValue(state(ev))
      append_callback(check, ev, op, event_state_values)
    end
    return op
  end
end

function Operator{E<:Environment}(eval::Function, fev::AbstractEvent{E}, events::AbstractEvent{E}...) :: Operator{E}
  Operator{E}(eval, fev, events...)
end

function check{E<:Environment}(ev::AbstractEvent{E}, op::Operator{E}, event_state_values::Dict{AbstractEvent{E}, StateValue})
  val = value(ev)
  if state(op) == idle
    if isa(val, Exception)
      schedule(op.bev, value=val)
    else
      event_state_values[ev] = StateValue(state(ev), val)
      if op.eval(collect(values(event_state_values)))
        schedule(op.bev, value=event_state_values)
      end
    end
  elseif state(op) == triggered
    if isa(val, Exception)
      schedule(op.bev, priority=true, value=val)
    else
      event_state_values[ev] = StateValue(state(ev), val)
    end
  end
end

function eval_and(state_values::Vector{StateValue})
  return all(map((sv)->sv.state == processed, state_values))
end

function eval_or(state_values::Vector{StateValue})
  return any(map((sv)->sv.state == processed, state_values))
end

function (&){E<:Environment}(ev1::AbstractEvent{E}, ev2::AbstractEvent{E})
  return Operator(eval_and, ev1, ev2)
end

function (|){E<:Environment}(ev1::AbstractEvent{E}, ev2::AbstractEvent{E})
  return Operator(eval_or, ev1, ev2)
end

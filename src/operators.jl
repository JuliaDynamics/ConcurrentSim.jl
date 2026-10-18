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
  subscriptions :: Vector{Tuple{AbstractEvent, Function}}
  abandonable :: Bool
  function Operator(eval::Function, fev::AbstractEvent, events::AbstractEvent...)
    inputs = tuple(fev, events...)
    for ev in inputs
      check_not_abandoned(ev)
      state(ev) === processed && throw(EventProcessed(ev))
    end
    env = environment(fev)
    op = new(BaseEvent(env), eval, Tuple{AbstractEvent, Function}[], any(abandon_on_unobserved, inputs))
    # Release inputs before consumer callbacks can resume their processes.
    @callback release_inputs(op)
    event_state_values = Dict{AbstractEvent, StateValue}()
    for ev in inputs
      event_state_values[ev] = StateValue(state(ev))
      cb = @callback check(ev, op, event_state_values)
      push!(op.subscriptions, (ev, cb))
    end
    op
  end
end

abandon_on_unobserved(op::Operator) = op.abandonable
# The first callback releases inputs and is not a subscriber.
has_subscribers(op::Operator) = length(op.bev.callbacks) > 1
on_abandon(op::Operator) = release_inputs(op)

function release_inputs(op::Operator)
  for (ev, cb) in op.subscriptions
    remove_callback(cb, ev)
  end
  empty!(op.subscriptions)
  nothing
end

function check(ev::AbstractEvent, op::Operator, event_state_values::Dict{AbstractEvent, StateValue})
  op.bev.abandoned && return nothing
  val = value(ev)
  if state(op) === idle
    if isa(val, Exception)
      schedule(op; value=val)
    else
      event_state_values[ev] = StateValue(state(ev), val)
      op.eval(collect(values(event_state_values))) && schedule(op; value=event_state_values)
    end
  elseif state(op) === scheduled
    if isa(val, Exception)
      schedule(op; priority=typemax(Int), value=val)
    else
      event_state_values[ev] = StateValue(state(ev), val)
    end
  end
end

function eval_and(state_values::Vector{StateValue})
  all(map((sv)->sv.state === processed, state_values))
end

function eval_or(state_values::Vector{StateValue})
  any(map((sv)->sv.state === processed, state_values))
end

function (&)(ev1::AbstractEvent, ev2::AbstractEvent)
  Operator(eval_and, ev1, ev2)
end

function (|)(ev1::AbstractEvent, ev2::AbstractEvent)
  Operator(eval_or, ev1, ev2)
end

function AllOf(events...)
  Operator(eval_and,events...)
end

function AnyOf(events...)
  Operator(eval_or,events...)
end

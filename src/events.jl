"""
  `value(ev::Event) :: Any`

Returns the value of the event.
"""
function value(ev::Event) :: Any
  return ev.value
end

"""
  `append_callback(ev::Event, cb::Function, args...)` :: Function

Adds a callback function to an event, i.e. a function having as first argument an object of type `Simulation` and as second argument the event. Optional arguments can be specified by `args...`.

If the event is being processed an [`EventProcessing`](@ref) exception is thrown.
"""
function append_callback(ev::Event, cb::Function, args::Any...) :: Function
  if (ev.state == processing) || (ev.state == processed)
    throw(EventProcessing())
  end
  func = (sim::Simulation, ev::Event)->cb(sim, ev, args...)
  ev.callbacks[func] = ev.cid+=0x1
  return func
end

function remove_callback(ev::Event, func::Function)
  dequeue!(ev.callbacks, func)
end

type StateValue
  state :: EVENT_STATE
  value :: Any
  function StateValue(state::EVENT_STATE, value::Any=nothing)
    new(state, value)
  end
end

function Event(eval::Function, fev::Event, events...)
  oper = Event()
  event_state_values = Dict{Event, StateValue}()
  for ev in tuple(fev, events...)
    if ev.state == processing
      throw(EventProcessing())
    else
      event_state_values[ev] = StateValue(ev.state)
      append_callback(ev, check, oper, eval, event_state_values)
    end
  end
  return oper
end

function check(sim::Simulation, ev::Event, oper::Event, eval::Function, event_state_values::Dict{Event, StateValue})
  if oper.state == idle
    if isa(ev.value, Exception)
      schedule(sim, oper, value=ev.value)
    else
      event_state_values[ev] = StateValue(ev.state, ev.value)
      if eval(collect(values(event_state_values)))
        schedule(sim, oper, value=event_state_values)
      end
    end
  elseif oper.state == triggered
    if isa(ev.value, Exception)
      schedule!(sim, oper, value=ev.value)
    else
      event_state_values[ev] = StateValue(ev.state, ev.value)
    end
  end
end

function eval_and(state_values::Vector{StateValue})
  return all(map((sv)->sv.state == processing, state_values))
end

function eval_or(state_values::Vector{StateValue})
  return any(map((sv)->sv.state == processing, state_values))
end

function (&)(ev1::Event, ev2::Event)
  return Event(eval_and, ev1, ev2)
end

function (|)(ev1::Event, ev2::Event)
  return Event(eval_or, ev1, ev2)
end

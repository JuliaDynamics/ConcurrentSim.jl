
"""
  `const EVENT_IDLE`

State representing an event that may happen but is not yet scheduled.
"""
const EVENT_IDLE = 0x0

"""
  `const EVENT_TRIGGERED`

State representing an event that is going to happen, i.e. is scheduled but processing has not yet been started.
"""
const EVENT_TRIGGERED = 0x1

"""
  `const EVENT_PROCESSING`

State representing an event that is happening.
"""
const EVENT_PROCESSING = 0x2

"""
  `Event`

An event is a state machine with three states:

- [`EVENT_IDLE`](@ref)
- [`EVENT_TRIGGERED`](@ref)
- [`EVENT_PROCESSING`](@ref)

Once the processing has ended, the event returns to an [`EVENT_IDLE`](@ref) state and can be scheduled again.

An event is initially not triggered. Events are scheduled for processing by the simulation after they are triggered.

An event has a list of callbacks and a value. A callback can be any function. Once an event gets processed, all callbacks will be invoked. Callbacks can do further processing with the value it has produced.

Failed events, i.e. events having as value an `Exception`, are never silently ignored and will raise this exception upon being processed.

**Fields:**

- `callbacks :: Vector{Function}`
- `state :: UInt`
- `value :: Any`

**Constructor:**

- `Event()`
- `Event(sim::Simulation, delay::Float64; priority::Bool=false, value::Any=nothing)`
"""
type Event
  callbacks :: Vector{Function}
  state :: UInt
  value :: Any
  function Event()
    ev = new()
    ev.callbacks = Function[]
    ev.state = EVENT_IDLE
    ev.value = nothing
    return ev
  end
end

"""
  `value(ev::Event) :: Any`

Returns the value of the event.
"""
function value(ev::Event) :: Any
  return ev.value
end

"""
  `state(ev::Event) :: EventState`

Returns the state of the event.
"""
function state(ev::Event) :: UInt
  return ev.state
end

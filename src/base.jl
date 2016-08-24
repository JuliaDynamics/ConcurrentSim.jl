"""
  `EVENT_STATE`

Enum with values:

- `idle=0`
- `triggered=1`
- `processing=2`
"""
@enum EVENT_STATE idle=0 triggered=1 processing=2

type Callback
  func :: Function
  sticky :: Bool
end

"""
  `Event`

An event is a state machine with three states:

- `idle`
- `triggered`
- `processing`

Once the processing has ended, the event returns to an `idle` state and can be scheduled again.

An event is initially not triggered. Events are scheduled for processing by the simulation after they are triggered.

An event has a list of callbacks and a value. A callback can be any function. Once an event gets processed, all callbacks will be invoked. Callbacks can do further processing with the value it has produced.

Failed events, i.e. events having as value an `Exception`, are never silently ignored and will raise this exception upon being processed.

**Fields:**

- `callbacks :: Vector{Function}`
- `state :: EVENT_STATE`
- `value :: Any`

**Constructor:**

- `Event()`
- `Event(sim::Simulation, delay::Period; priority::Bool=false, value::Any=nothing)`
- `Event(sim::Simulation, delay::Number=0; priority::Bool=false, value::Any=nothing)`
"""
type Event
  callbacks :: Vector{Callback}
  state :: EVENT_STATE
  value :: Any
  cid :: UInt
  function Event()
    ev = new()
    ev.callbacks = Callback[]
    ev.state = idle
    ev.value = nothing
    ev.cid = 0x0
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
function state(ev::Event) :: EVENT_STATE
  return ev.state
end

"""
  `EventNotIdle <: Exception`

Exception thrown when an event is scheduled ([`schedule`](@ref))  that has already been scheduled or is being processed.

Only used internally.
"""

type EventNotIdle <: Exception end

"""
  `EventProcessing <: Exception`

Exception thrown:

- when a callback is added to an event ([`append_callback`](@ref)) that is being processed or
- when an event is scheduled ([`schedule!`](@ref)) that is being processed.

Only used internally.
"""
type EventProcessing <: Exception end

"""
  `StopSimulation <: Exception`

Exception that stops the simulation. A return value can be set.

**Fields**:

- `value :: Any`

**Constructor**:

`StopSimulation(value::Any=nothing)`
"""
type StopSimulation <: Exception
  value :: Any
  function StopSimulation(value::Any=nothing)
    new(value)
  end
end

"""
  `EventKey`

Key for the event heap.

**Fields**:

- `time :: Float64`
- `priority :: Bool`
- `id :: UInt`

**Constructor**:

`EventKey(time :: Float64, priority :: Bool, id :: UInt`)

Only used internally.
"""
immutable EventKey
  time :: TimeType
  priority :: Bool
  id :: UInt
end

"""
  `isless(a::EventKey, b::EventKey) :: Bool`

Compairs two `EventKey`. The criteria in order of importance are:

- time of processing
- priority when time of processing is equal
- scheduling id, i.e. the event that was first scheduled is first processed when time of processing and priority are identical

Only used internally.
"""
function isless(a::EventKey, b::EventKey) :: Bool
  (a.time < b.time) || (a.time == b.time && a.priority > b.priority) || (a.time == b.time && a.priority == b.priority && a.id < b.id)
end

immutable SimulationPeriod <: Period
  value :: Float64
  function SimulationPeriod(value::Number=0)
    new(value)
  end
end

immutable SimulationInstant <: Dates.Instant
  periods :: SimulationPeriod
end

immutable SimulationTime <: TimeType
  instant :: SimulationInstant
end

function SimulationTime(value::Number=0)
  SimulationTime(SimulationInstant(SimulationPeriod(value)))
end

(==)(x::SimulationTime, y::SimulationTime) = x.instant.periods.value == y.instant.periods.value

function isless(t1::SimulationTime, t2::SimulationTime) :: Bool
  t1.instant.periods.value < t2.instant.periods.value
end

(+)(t::SimulationTime, p::SimulationPeriod)=SimulationTime(t.instant.periods.value + p.value)

function show(io::IO, t::SimulationTime)
  print(io, "$(t.instant.periods.value)")
end

"""
  `Simulation{T<:TimeType}`

Execution environment for a simulation. The passing of time is implemented by stepping from event to event.

**Fields**:

- `time :: T`
- `heap :: PriorityQueue{Event, EventKey}`
- `sid :: UInt`

**Constructor**:

`Simulation{T<:TimeType}(initial_time::T)`
`Simulation(initial_time::Number=0)`

An initial_time for the simulation can be specified. By default, it starts at 0.
"""
type Simulation{T<:TimeType}
  time :: T
  heap :: PriorityQueue{Event, EventKey}
  sid :: UInt
  granularity :: Type
  function Simulation(initial_time::T)
    sim = new()
    sim.time = initial_time
    sim.heap = PriorityQueue(Event, EventKey)
    sim.sid = 0x0
    sim.granularity = typeof(initial_time.instant.periods)
    return sim
  end
end

function Simulation{T<:TimeType}(initial_time::T)
  Simulation{T}(initial_time)
end

function Simulation(initial_time::Number=0)
  Simulation(SimulationTime(initial_time))
end

"""
  - `run(sim::Simulation, until::Event)`
  - `run(sim::Simulation, until::TimeType)`
  - `run(sim::Simulation, until::Period)`
  - `run(sim::Simulation, until::Number)`
  - `run(sim::Simulation)`

Executes [`step`](@ref) until the given criterion `until` is met:

- if it is not specified, the method will return when there are no further events to be processed
- if it is an `Event`, the method will continue stepping until this event has been triggered and will return its value
- if it is a `TimeType`, the method will continue stepping until the simulation’s time reaches until
- if it is a `Period`, the method will continue stepping until the simulation’s time has passed until periods
- if it is a `Number`, the method will continue stepping until the simulation’s time has passed until elementary periods

In the last two cases, the simulation can prematurely stop when there are no further events to be processed.
"""
function run(sim::Simulation, until::Event=Event()) :: Any
  append_callback(until, stop_simulation, include_event=true)
  try
    while step(sim) end
    return nothing
  catch exc
    if isa(exc, StopSimulation)
      return exc.value
    else
      rethrow(exc)
    end
  end
end

function run(sim::Simulation, until::Period) :: Any
  run(sim, Event(sim, until))
end

function run(sim::Simulation, until::TimeType) :: Any
  run(sim, Event(sim, now(sim)-until))
end

function run(sim::Simulation, until::Number) :: Any
  run(sim, Event(sim, sim.granularity(until)))
end

function stop_simulation(sim::Simulation, ev::Event)
  throw(StopSimulation(ev.value))
end

"""
  `now(sim::Simulation) :: TimeType`

Returns the current simulation time.
"""
function now(sim::Simulation) :: TimeType
  return sim.time
end

"""
  - `schedule!(sim::Simulation, ev::Event, delay::Period; priority::Bool=false, value::Any=nothing) :: Event`
  - `schedule!(sim::Simulation, ev::Event, delay::Number=0; priority::Bool=false, value::Any=nothing) :: Event`

Schedules an event at time `sim.time + delay` with a `priority` and a `value`.

If the event is already scheduled, the key is updated with the new `delay` and `priority`. The new `value` is also set.

If the event is being processed, an [`EventProcessing`](@ref) exception is thrown.
"""
function schedule!(sim::Simulation, ev::Event, delay::Period; priority::Bool=false, value::Any=nothing) :: Event
  if ev.state == processing
    throw(EventProcessing)
  end
  ev.value = value
  if ev.state == triggered
    id = sim.heap[ev].id
  else
    ev.state = triggered
    id = sim.sid+=1
  end
  sim.heap[ev] = EventKey(sim.time + delay, priority, id)
  return ev
end

function schedule!(sim::Simulation, ev::Event, delay::Number=0; priority::Bool=false, value::Any=nothing) :: Event
  schedule!(sim, ev, sim.granularity(delay), priority=priority, value=value)
end

"""
  - `schedule(sim::Simulation, ev::Event, delay::Period; priority::Bool=false, value::Any=nothing) :: Event`
  - `schedule(sim::Simulation, ev::Event, delay::Number=0; priority::Bool=false, value::Any=nothing) :: Event`

Schedules an event at time `sim.time + delay` with a `priority` and a `value`.

If the event is already scheduled or is being processed, an [`EventNotIdle`](@ref) exception is thrown.
"""
function schedule(sim::Simulation, ev::Event, delay::Period; priority::Bool=false, value::Any=nothing) :: Event
  if ev.state == triggered || ev.state == processing
    throw(EventNotIdle)
  end
  ev.value = value
  ev.state = triggered
  sim.heap[ev] = EventKey(sim.time + delay, priority, sim.sid+=1)
  return ev
end

function schedule(sim::Simulation, ev::Event, delay::Number=0; priority::Bool=false, value::Any=nothing) :: Event
  schedule(sim, ev, sim.granularity(delay), priority=priority, value=value)
end

function Event(sim::Simulation, delay::Period; priority::Bool=false, value::Any=nothing)
  schedule(sim, Event(), delay, priority=priority, value=value)
end

function Event(sim::Simulation, delay::Number; priority::Bool=false, value::Any=nothing)
  schedule(sim, Event(), delay, priority=priority, value=value)
end

type StateValue
  state :: EVENT_STATE
  value :: Any
end

function StateValue(state::EVENT_STATE)
  StateValue(state, nothing)
end

function Event(eval::Function, fev::Event, events...)
  oper = Event()
  event_state_values = Dict{Event, StateValue}()
  for ev in tuple(fev, events...)
    if ev.state == processing
      throw(EventProcessing())
    else
      event_state_values[ev] = StateValue(ev.state)
      append_callback(ev, check, oper, eval, event_state_values, include_event=true)
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

"""
  `step(sim::Simulation) :: Bool`

Does a simulation step and processes the next event.

Only used internally.
"""
function step(sim::Simulation) :: Bool
  if isempty(sim.heap)
    return false
  end
  (ev, key) = peek(sim.heap)
  dequeue!(sim.heap)
  ev.state = processing
  sim.time = key.time
  to_del = Int[]
  for (i, cb) in enumerate(ev.callbacks)
    if !cb.sticky
      push!(to_del, i)
    end
    cb.func(sim)
  end
  deleteat!(ev.callbacks, to_del)
  ev.state = idle
  return true
end

"""
  `append_callback(ev::Event, cb::Function, args...; include_event::Bool=false, sticky::Bool=false)` :: Function

Adds a callback function, i.e. a function having as first argument an object of type `Simulation`, to the event. The second argument is the event if `include_event=true`. Optional arguments can be specified by `args...`.
The `sticky` keyword argument allows to keep a callback function when reusing an event. The default behavior is to remove the callback functions at the end of the processing.

If the event is being processed an [`EventProcessing`](@ref) exception is thrown.

Callback functions are called in order of adding to the event.
"""
function append_callback(ev::Event, cb::Function, args...; include_event::Bool=false, sticky::Bool=false) :: Function
  if ev.state == processing
    throw(EventProcessing())
  end
  if include_event
    func = (sim::Simulation)->cb(sim, ev, args...)
  else
    func = (sim::Simulation)->cb(sim, args...)
  end
  push!(ev.callbacks, Callback(func, sticky))
  return func
end

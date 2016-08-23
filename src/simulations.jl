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
  function SimulationPeriod(value::Number=0.0)
    new(value)
  end
end

immutable SimulationTime <: TimeType
  value :: Float64
  function SimulationTime(initial_value::Number=0.0)
    new(initial_value)
  end
end

(==)(x::SimulationTime, y::SimulationTime) = x.value == y.value

function isless(t1::SimulationTime, t2::SimulationTime) :: Bool
  t1.value < t2.value
end

(+)(t::SimulationTime, p::SimulationPeriod)=SimulationTime(t.value + p.value)

function show(io::IO, t::SimulationTime)
  print(io, "$(t.value)")
end

"""
  `Simulation`

Execution environment for a simulation. The passing of time is implemented by stepping from event to event.

**Fields**:

- `time :: Float64`
- `heap :: PriorityQueue{Event, EventKey}`
- `sid :: UInt`

**Constructor**:

`Simulation(initial_time::Float64=0.0)`

An initial_time for the simulation can be specified. By default, it starts at 0.0.
"""
type Simulation{T<:TimeType}
  time :: T
  heap :: PriorityQueue{Event, EventKey}
  sid :: UInt
  function Simulation(initial_time::T)
    sim = new()
    sim.time = initial_time
    sim.heap = PriorityQueue(Event, EventKey)
    sim.sid = 0x0
    return sim
  end
end

function Simulation{T<:TimeType}(initial_time::T)
  Simulation{T}(initial_time)
end

function Simulation(initial_time::Number=0.0)
  Simulation{SimulationTime}(SimulationTime(initial_time))
end

"""
  - `run(sim::Simulation, until::Event)`
  - `run(sim::Simulation, until::Float64)`
  - `run(sim::Simulation)`

Executes [`step`](@ref) until the given criterion `until` is met:

- if it is not specified, the method will return when there are no further events to be processed
- if it is an `Event`, the method will continue stepping until this event has been triggered and will return its value
- if it is a `Float64`, the method will continue stepping until the environment’s time reaches until

In the last two cases, the simulation can prematurely stop when there are no further events to be processed.
"""
function run(sim::Simulation, until::Event=Event()) :: Any
  append_callback(until, stop_environment)
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

function run(sim::Simulation, until::Float64) :: Any
  run(sim, Event(sim, SimulationPeriod(until)))
end

function stop_environment(ev::Event)
  throw(StopEnvironment(ev.value))
end

"""
  `now(sim::Simulation) :: Float64`

Returns the current simulation time.
"""
function now(sim::Simulation) :: TimeType
  return sim.time
end

"""
  `schedule!(sim::Simulation, ev::Event, delay::Float64=0.0; priority::Bool=false, value::Any=nothing) :: Event`

Schedules an event at time `sim.time + delay` with a `priority` and a `value`.

If the event is already scheduled, the key is updated with the new `delay` and `priority`. The new `value` is also set.

If the event is being processed, an [`EventProcessing`](@ref) exception is thrown.
"""
function schedule!(sim::Simulation, ev::Event, delay::Period; priority::Bool=false, value::Any=nothing) :: Event
  if ev.state == EVENT_PROCESSING
    throw(EventProcessing)
  end
  ev.value = value
  if ev.state == EVENT_TRIGGERED
    id = sim.heap[ev].id
  else
    ev.state = EVENT_TRIGGERED
    id = sim.sid+=1
  end
  sim.heap[ev] = EventKey(sim.time + delay, priority, id)
  return ev
end

function schedule!(sim::Simulation, ev::Event, delay::Float64=0.0; priority::Bool=false, value::Any=nothing) :: Event
  schedule!(sim, ev, SimulationPeriod(delay), priority=priority, value=value)
end

"""
  `schedule(sim::Simulation, ev::Event, delay::Float64=0.0; priority::Bool=false, value::Any=nothing) :: Event`

Schedules an event at time `sim.time + delay` with a `priority` and a `value`.

If the event is already scheduled or is beign processed, an [`EventNotIdle`](@ref) exception is thrown.
"""
function schedule(sim::Simulation, ev::Event, delay::Period; priority::Bool=false, value::Any=nothing) :: Event
  if ev.state == EVENT_TRIGGERED || ev.state == EVENT_PROCESSING
    throw(EventNotIdle)
  end
  ev.value = value
  ev.state = EVENT_TRIGGERED
  sim.heap[ev] = EventKey(sim.time + delay, priority, sim.sid+=1)
  return ev
end

function schedule(sim::Simulation, ev::Event, delay::Number; priority::Bool=false, value::Any=nothing) :: Event
  schedule(sim, ev, SimulationPeriod(delay), priority=priority, value=value)
end

function schedule(sim::Simulation, ev::Event; priority::Bool=false, value::Any=nothing) :: Event
  delay = typeof(sim.time.instant.periods)(0)
  schedule(sim, ev, delay, priority=priority, value=value)
end

function Event(sim::Simulation, delay::Period; priority::Bool=false, value::Any=nothing)
  schedule(sim, Event(), delay, priority=priority, value=value)
end

function Event(sim::Simulation, delay::Float64; priority::Bool=false, value::Any=nothing)
  schedule(sim, Event(), SimulationPeriod(delay), priority=priority, value=value)
end

type StateValue
  state :: UInt
  value :: Any
end

function StateValue(state::UInt)
  StateValue(state, nothing)
end

function Event(eval::Function, fev::Event, events...)
  oper = Event()
  event_state_values = Dict{Event, StateValue}()
  for ev in tuple(fev, events...)
    if ev.state == EVENT_PROCESSING
      throw(EventProcessing())
    else
      event_state_values[ev] = StateValue(ev.state)
      append_callback(ev, (sim::Simulation)->check(sim, oper, ev, eval, event_state_values))
    end
  end
  return oper
end

function check(sim::Simulation, oper::Event, ev::Event, eval::Function, event_state_values::Dict{Event, StateValue})
  if oper.state == EVENT_IDLE
    if isa(ev.value, Exception)
      schedule(oper, ev.value)
    else
      event_state_values[ev] = StateValue(ev.state, ev.value)
      if eval(collect(values(event_state_values)))
        schedule(sim, oper, value=event_state_values)
      end
    end
  end
end

function eval_and(state_values::Vector{StateValue})
  return all(map((sv)->sv.state == EVENT_PROCESSING, state_values))
end

function (&)(ev1::Event, ev2::Event)
  return Event(eval_and, ev1, ev2)
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
  ev.state = EVENT_PROCESSING
  sim.time = key.time
  while !isempty(ev.callbacks)
    cb = shift!(ev.callbacks)
    cb(sim)
  end
  ev.state = EVENT_IDLE
  return true
end

"""
  `append_callback(ev::Event, cb::Function, args...)`

Adds a callback function to the event. Optional arguments to the callback function can be specified by `args...`. If the event is being processed an [`EventProcessing`](@ref) exception is thrown.

Callback functions are called in order of adding to the event.
"""
function append_callback(ev::Event, cb::Function, args...)
  if ev.state == EVENT_PROCESSING
    throw(EventProcessing())
  end
  push!(ev.callbacks, (sim::Simulation)->cb(sim, args...))
end

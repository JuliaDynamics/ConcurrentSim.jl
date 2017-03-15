struct EventKey{T<:TimeType}
  time :: T
  priority :: Int8
  id :: UInt
end

function isless{T<:TimeType}(a::EventKey{T}, b::EventKey{T}) :: Bool
  (a.time < b.time) || (a.time == b.time && a.priority > b.priority) || (a.time == b.time && a.priority == b.priority && a.id < b.id)
end

abstract type AbstractProcess{E<:Environment} <: AbstractEvent{E} end

"""
Execution environment for a simulation.

The passing of time is implemented by stepping from event to event.

**Signature**:
Simulation{T<:TimeType} <: Environment

**Fields**:

- time :: T
- heap :: PriorityQueue{BaseEvent{Simulation{T}}, EventKey{T}}
- eid :: UInt
- sid :: UInt
- active_proc :: Nullable{AbstractProcess}

**Constructors**:

- Simulation{T<:TimeType}(initial_time::T) :: Simulation{T}
- Simulation(initial_time::Number=0) :: Simulation{SimulationTime}

An initial_time for the simulation can be specified. By default, it starts at 0.
"""
mutable struct Simulation{T<:TimeType} <: Environment
  time :: T
  heap :: DataStructures.PriorityQueue{BaseEvent{Simulation{T}}, EventKey{T}}
  eid :: UInt
  sid :: UInt
  active_proc :: Nullable{AbstractProcess{Simulation{T}}}
  function Simulation{T}(initial_time::T) where T<:TimeType
    new(initial_time, DataStructures.PriorityQueue(BaseEvent{Simulation{T}}, EventKey{T}), zero(UInt), zero(UInt), Nullable{AbstractProcess{Simulation{T}}}())
  end
end

function Simulation{T<:TimeType}(initial_time::T)
  Simulation{T}(initial_time)
end

function Simulation(initial_time::Number=0) :: Simulation{SimulationTime}
  Simulation{SimulationTime}(SimulationTime(initial_time))
end

"""
Returns the current simulation time.

**Method**:
now{T<:TimeType}(sim::Simulation{T}) :: T
"""
function now{T<:TimeType}(sim::Simulation{T}) :: T
  sim.time
end

function active_process{T<:TimeType}(sim::Simulation{T}) :: AbstractProcess{Simulation{T}}
  get(sim.active_proc)
end

function set_active_process{T<:TimeType}(sim::Simulation{T})
  sim.active_proc = Nullable{AbstractProcess{Simulation{T}}}()
end

function set_active_process{T<:TimeType}(sim::Simulation{T}, proc::AbstractProcess{Simulation{T}})
  sim.active_proc = Nullable(proc)
end

immutable StopSimulation <: Exception
  value :: Any
  function StopSimulation(value::Any=nothing)
    new(value)
  end
end

function stop_simulation(ev::AbstractEvent)
  throw(StopSimulation(value(ev)))
end

immutable EmptySchedule <: Exception end

"""
Does a simulation step and processes the next event.

**Method**:

step(sim::Simulation) :: Bool
"""
function step(sim::Simulation)
  isempty(sim.heap) && throw(EmptySchedule())
  (bev, key) = DataStructures.peek(sim.heap)
  DataStructures.dequeue!(sim.heap)
  sim.time = key.time
  bev.state = triggered
  while !isempty(bev.callbacks)
    DataStructures.dequeue!(bev.callbacks)()
  end
end

"""
Executes [`step`](@ref) until the given criterion is met:

- if nothing is not specified, the method will return when there are no further events to be triggered
- if it is a subtype of `AbstractEvent`, the simulation will continue stepping until this event has been triggered and will return its value
- if it is a subtype of `TimeType`, the simulation will continue stepping until the simulation’s time reaches until
- if it is a subtype of `Period`, the simulation will continue stepping during the given period
- if it is a subtype of `Number`, the method will continue stepping during a period of elementary time units

In the first two cases, the simulation can prematurely stop when there are no further events to be triggered.

If the stepping end with a `StopSimulation` exception the function return the value of the exception, in all other cases the exception is rethrown.

**Methods**:

  - run(sim::Simulation, until::AbstractEvent) :: Any
  - run{T<:TimeType}(sim::Simulation{T}, until::T) :: Any
  - run(sim::Simulation, period::Union{Period, Number}) :: Any
  - run(sim::Simulation) :: Any
"""
function run{T<:TimeType}(sim::Simulation{T}, until::AbstractEvent{Simulation{T}}) :: Any
  append_callback(stop_simulation, until)
  try
    while true
      step(sim)
    end
  catch exc
    if isa(exc, StopSimulation)
      return exc.value
    else
      rethrow(exc)
    end
  end
end

function run(sim::Simulation, period::Union{Period, Number}) :: Any
  run(sim, Timeout(sim, period))
end

function run{T<:TimeType}(sim::Simulation{T}, until::T) :: Any
  run(sim, until-sim.time)
end

function run(sim::Simulation) :: Any
  run(sim, typemax(sim.time)-sim.time)
end

function schedule{T<:TimeType}(bev::BaseEvent{Simulation{T}}, delay::Period; priority::Int8=Int8(0), value::Any=nothing)
  bev.value = value
  bev.env.heap[bev] = EventKey{T}(bev.env.time + delay, priority, bev.env.sid+=one(UInt))
  bev.state = scheduled
end

function schedule{T<:TimeType}(bev::BaseEvent{Simulation{T}}, delay::Number=0; priority::Int8=Int8(0), value::Any=nothing)
  P = typeof(eps(bev.env.time))
  schedule(bev, P(delay), priority=priority, value=value)
end

struct InterruptException{E<:Environment} <: Exception
  by :: AbstractProcess{E}
  cause :: Any
end

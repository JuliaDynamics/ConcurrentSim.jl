abstract type AbstractProcess <: AbstractEvent end
abstract type DiscreteProcess <: AbstractProcess end

struct InterruptException <: Exception
  by :: AbstractProcess
  cause :: Any
end

struct EmptySchedule <: Exception end

struct EventKey
  time :: Float64
  priority :: Int8
  id :: UInt
end

function isless(a::EventKey, b::EventKey) :: Bool
  (a.time < b.time) || (a.time == b.time && a.priority > b.priority) || (a.time == b.time && a.priority == b.priority && a.id < b.id)
end

mutable struct Simulation <: Environment
  time :: Float64
  heap :: DataStructures.PriorityQueue{BaseEvent, EventKey}
  eid :: UInt
  sid :: UInt
  active_proc :: Nullable{AbstractProcess}
  function Simulation(initial_time::Number=zero(Float64))
    new(initial_time, DataStructures.PriorityQueue{BaseEvent, EventKey}(), zero(UInt), zero(UInt), Nullable{AbstractProcess}())
  end
end

function step(sim::Simulation)
  isempty(sim.heap) && throw(EmptySchedule())
  (bev, key) = DataStructures.peek(sim.heap)
  DataStructures.dequeue!(sim.heap)
  sim.time = key.time
  bev.state = processed
  for callback in bev.callbacks
    callback()
  end
end

function now(sim::Simulation)
  sim.time
end

function now(ev::AbstractEvent)
  return now(environment(ev))
end

function active_process(sim::Simulation) :: AbstractProcess
  get(sim.active_proc)
end

function reset_active_process(sim::Simulation)
  sim.active_proc = Nullable{AbstractProcess}()
end

function set_active_process(sim::Simulation, proc::AbstractProcess)
  sim.active_proc = Nullable(proc)
end

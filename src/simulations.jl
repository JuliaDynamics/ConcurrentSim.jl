abstract type AbstractProcess <: AbstractEvent end

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
    new(initial_time, DataStructures.PriorityQueue(BaseEvent, EventKey), zero(UInt), zero(UInt), Nullable{AbstractProcess}())
  end
end

function now(sim::Simulation)
  sim.time
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

struct StopSimulation <: Exception
  value :: Any
  function StopSimulation(value::Any=nothing)
    new(value)
  end
end

function stop_simulation(ev::AbstractEvent)
  throw(StopSimulation(value(ev)))
end

struct EmptySchedule <: Exception end

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

function run(sim::Simulation, until::AbstractEvent)
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

function schedule(bev::BaseEvent, delay::Number=zero(Float64); priority::Int8=zero(Int8), value::Any=nothing)
  bev.value = value
  bev.env.heap[bev] = EventKey(bev.env.time + delay, priority, bev.env.sid+=one(UInt))
  bev.state = scheduled
end

struct InterruptException <: Exception
  by :: AbstractProcess
  cause :: Any
end

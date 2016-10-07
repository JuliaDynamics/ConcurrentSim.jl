immutable EventKey{T<:TimeType}
  time :: T
  priority :: Bool
  id :: UInt
end

function isless{T<:TimeType}(a::EventKey{T}, b::EventKey{T}) :: Bool
  (a.time < b.time) || (a.time == b.time && a.priority > b.priority) || (a.time == b.time && a.priority == b.priority && a.id < b.id)
end

type Simulation{T<:TimeType} <: Environment
  time :: T
  heap :: PriorityQueue{BaseEvent{Simulation{T}}, EventKey{T}}
  eid :: UInt
  sid :: UInt
  active_proc :: Nullable{Process{Simulation{T}}}
  function Simulation(initial_time::T)
    new(initial_time, PriorityQueue(BaseEvent{Simulation{T}}, EventKey{T}), zero(UInt), zero(UInt), Nullable{Process{Simulation{T}}}())
  end
end

function Simulation{T<:TimeType}(initial_time::T) :: Simulation{T}
  Simulation{T}(initial_time)
end

function Simulation(initial_time::Number=0) :: Simulation{SimulationTime}
  Simulation(SimulationTime(initial_time))
end

function now{T<:TimeType}(sim::Simulation{T}) :: T
  sim.time
end

function active_process{T<:TimeType}(sim::Simulation{T}) :: Process{Simulation{T}}
  get(sim.active_proc)
end

function set_active_process{T<:TimeType}(sim::Simulation{T})
  sim.active_proc = Nullable{Process{Simulation{T}}}()
end

function set_active_process{T<:TimeType}(sim::Simulation{T}, proc::Process{Simulation{T}})
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

function step(sim::Simulation)
  if isempty(sim.heap)
    throw(EmptySchedule())
  end
  (bev, key) = peek(sim.heap)
  dequeue!(sim.heap)
  sim.time = key.time
  bev.state = processed
  while !isempty(bev.callbacks)
    dequeue!(bev.callbacks)()
  end
end

function run(sim::Simulation, until::AbstractEvent) :: Any
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

function run(sim::Simulation, period::Period) :: Any
  run(sim, timeout(sim, period))
end

function run(sim::Simulation, period::Number) :: Any
  run(sim, eps(sim.time)*period)
end

function run{T<:TimeType}(sim::Simulation{T}, until::T) :: Any
  run(sim, until-sim.time)
end

function run(sim::Simulation) :: Any
  run(sim, typemax(sim.time)-sim.time)
end

function schedule{T<:TimeType}(bev::BaseEvent{Simulation{T}}, delay::Period; priority::Bool=false, value::Any=nothing)
  bev.value = value
  bev.env.heap[bev] = EventKey(bev.env.time + delay, priority, bev.env.sid+=one(UInt))
  bev.state = triggered
end

function schedule{T<:TimeType}(bev::BaseEvent{Simulation{T}}, delay::Number=0; priority::Bool=false, value::Any=nothing)
  schedule(bev, eps(bev.env.time)*delay, priority=priority, value=value)
end

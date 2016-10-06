immutable EventKey
  time :: TimeType
  priority :: Bool
  id :: UInt
end

function isless(a::EventKey, b::EventKey) :: Bool
  (a.time < b.time) || (a.time == b.time && a.priority > b.priority) || (a.time == b.time && a.priority == b.priority && a.id < b.id)
end

type Simulation{T<:TimeType} <: Environment
  time :: T
  heap :: PriorityQueue{BaseEvent{Simulation{T}}, EventKey}
  eid :: UInt
  sid :: UInt
  active_proc :: Nullable{Process}
  function Simulation(initial_time::T)
    sim = new()
    sim.time = initial_time
    sim.heap = PriorityQueue(BaseEvent{Simulation{T}}, EventKey)
    sim.eid = zero(UInt)
    sim.sid = zero(UInt)
    sim.active_proc = Nullable{Process}()
    return sim
  end
end

function Simulation{T<:TimeType}(initial_time::T) :: Simulation{T}
  Simulation{T}(initial_time)
end

function Simulation(initial_time::Number=0) :: Simulation{SimulationTime}
  Simulation(SimulationTime(initial_time))
end

function now(sim::Simulation)
  sim.time
end

function active_process(sim::Simulation)
  get(sim.active_proc)
end

type StopSimulation <: Exception
  value :: Any
  function StopSimulation(value::Any=nothing)
    new(value)
  end
end

function stop_simulation(ev::AbstractEvent)
  throw(StopSimulation(ev.bev.value))
end

type EmptySchedule <: Exception end

function step(sim::Simulation)
  if isempty(sim.heap)
    throw(EmptySchedule())
  end
  (bev, key) = peek(sim.heap)
  dequeue!(sim.heap)
  sim.time = key.time
  bev.state = processed
  while !isempty(bev.callbacks)
    cb = dequeue!(bev.callbacks)
    cb()
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
  sim = bev.env
  bev.value = value
  sim.heap[bev] = EventKey(sim.time + delay, priority, sim.sid+=one(UInt))
  bev.state = triggered
end

function schedule{T<:TimeType}(bev::BaseEvent{Simulation{T}}, delay::Number=0; priority::Bool=false, value::Any=nothing)
  schedule(bev, eps(bev.env.time)*delay, priority=priority, value=value)
end

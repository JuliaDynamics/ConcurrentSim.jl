typealias StopSimulation StopEnvironment

type EventKey
  time :: Float64
  priority :: Bool
  id :: UInt
end

function isless(a::EventKey, b::EventKey)
  return (a.time < b.time) || (a.time == b.time && a.priority > b.priority) || (a.time == b.time && a.priority == b.priority && a.id < b.id)
end

type Simulation <: Environment
  time :: Float64
  heap :: PriorityQueue{Event, EventKey}
  eid :: UInt
  sid :: UInt
  function Simulation(initial_time::Float64=0.0)
    sim = new()
    sim.time = initial_time
    sim.heap = PriorityQueue(Event, EventKey)
    sim.eid = 0x0
    sim.sid = 0x0
    return sim
  end
end

function now(sim::Simulation)
  return sim.time
end

function schedule(sim::Simulation, ev::Event, priority::Bool, delay::Float64, value=nothing)
  if ev.processing
    throw(EventProcessing)
  end
  ev.value = value
  if in(ev, keys(sim.heap))
    key = sim.heap[ev]
    sim.heap[ev] = EventKey(sim.time + delay, priority, key.id)
  else
    sim.heap[ev] = EventKey(sim.time + delay, priority, sim.sid+=1)
  end
end

function schedule(sim::Simulation, ev::Event, priority::Bool, value=nothing)
  schedule(sim, ev, priority, 0.0, value)
end

function schedule(sim::Simulation, ev::Event, delay::Float64, value=nothing)
  schedule(sim, ev, false, delay, value)
end

function schedule(sim::Simulation, ev::Event, value=nothing)
  schedule(sim, ev, false, 0.0, value)
end

function step(sim::Simulation)
  if isempty(sim.heap)
    return false
  end
  (ev, key) = peek(sim.heap)
  dequeue!(sim.heap)
  sim.time = key.time
  ev.processing = true
  for cb in ev.callbacks
    cb(ev)
  end
  ev.processing = false
  return true
end

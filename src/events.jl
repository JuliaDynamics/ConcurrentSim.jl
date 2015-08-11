const EVENT_TRIGGERED = 1
const EVENT_PROCESSED = 2

type Event <: BaseEvent
  env :: BaseEnvironment
  callbacks :: Set{Function}
  state :: Uint16
  id :: Uint16
  value :: Any
  function Event(env::BaseEnvironment)
    ev = new()
    ev.env = env
    ev.callbacks = Set{Function}()
    ev.state = 0
    ev.id = 0
    return ev
  end
end

type EmptySchedule <: Exception end

type StopSimulation <: Exception end

type EventProcessed <: Exception end

function show(io::IO, ev::Event)
  print(io, "Event id $(ev.id)")
end

function triggered(ev::Event)
  return ev.state == EVENT_TRIGGERED
end

function processed(ev::Event)
  return ev.state == EVENT_PROCESSED
end

function value(ev::Event)
  return ev.value
end

function environment(ev::Event)
  return ev.env
end

function schedule(ev::Event, priority::Bool, delay::Float64, value=nothing)
  ev.env.eid += 1
  ev.id = ev.env.eid
  ev.env.sched[ev] = EventKey(ev.env.time + delay, priority, ev.id)
  ev.value = value
  ev.state = EVENT_TRIGGERED
end

function schedule(ev::Event, priority::Bool, value=nothing)
  schedule(ev, priority, 0.0, value)
end

function schedule(ev::Event, delay::Float64, value=nothing)
  schedule(ev, false, delay, value)
end

function schedule(ev::Event, value=nothing)
  schedule(ev, false, 0.0, value)
end

function append_callback(ev::Event, callback::Function, args...)
  if processed(ev)
    throw(EventProcessed())
  end
  push!(ev.callbacks, (ev)->callback(ev, args...))
end

function succeed(ev::Event, value=nothing)
  schedule(ev, value)
end

function fail(ev::Event, exc::Exception)
  schedule(ev, exc)
end

function run(env::BaseEnvironment)
  ev = Event(env)
  return run(env, ev)
end

function run(env::BaseEnvironment, at::Float64)
  ev = Event(env)
  schedule(ev, at)
  return run(env, ev)
end

function run(env::BaseEnvironment, until::BaseEvent)
  append_callback(until, stop_simulation)
  try
    while true
      step(env)
    end
  catch exc
    if isa(exc, StopSimulation)
      return value(until)
    elseif !isa(exc, EmptySchedule)
      rethrow(exc)
    end
  end
end

function exit(env::BaseEnvironment)
  throw(StopSimulation())
end

function stop_simulation(ev::Event)
  exit(ev.env)
end

function Timeout(env::BaseEnvironment, delay::Float64, value=nothing)
  ev = Event(env)
  schedule(ev, delay, value)
  return ev
end

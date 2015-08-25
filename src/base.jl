const EVENT_INITIAL = 0
const EVENT_TRIGGERED = 1
const EVENT_PROCESSING = 2
const EVENT_PROCESSED = 3

abstract AbstractEvent
abstract AbstractEnvironment

type EmptySchedule <: Exception end
type StopSimulation <: Exception
  value :: Any
end
type EventTriggered <: Exception end
type EventProcessed <: Exception end

type EventKey
  time :: Float64
  priority :: Bool
  id :: Float64
  ev :: AbstractEvent
end

type BaseEvent
  env :: AbstractEnvironment
  callbacks :: Set{Function}
  state :: Uint16
  id :: Int64
  value :: Any
  function BaseEvent(env::AbstractEnvironment)
    ev = new()
    ev.env = env
    ev.callbacks = Set{Function}()
    ev.state = EVENT_INITIAL
    ev.id = env.eid += 1
    ev.value = nothing
    return ev
  end
end

function isless(a::EventKey, b::EventKey)
  return (a.time < b.time) || (a.time == b.time && a.priority > b.priority) || (a.time == b.time && a.priority == b.priority && a.id < b.id)
end

function show(io::IO, ev::AbstractEvent)
  print(io, "$(typeof(ev)) $(ev.bev.id)")
end

function schedule(ev::AbstractEvent, priority::Bool, delay::Float64, value=nothing)
  env = ev.bev.env
  env.sched[ev.bev] = EventKey(env.time + delay, priority, env.seid += 1, ev)
  ev.bev.value = value
  ev.bev.state = EVENT_TRIGGERED
end

function schedule(ev::AbstractEvent, priority::Bool, value=nothing)
  schedule(ev, priority, 0.0, value)
end

function schedule(ev::AbstractEvent, delay::Float64, value=nothing)
  schedule(ev, false, delay, value)
end

function schedule(ev::AbstractEvent, value=nothing)
  schedule(ev, false, 0.0, value)
end

function run(env::AbstractEnvironment)
  ev = Event(env)
  return run(env, ev)
end

function run(env::AbstractEnvironment, until::Float64)
  ev = Event(env)
  schedule(ev, until)
  return run(env, ev)
end

function run(env::AbstractEnvironment, until::AbstractEvent)
  push!(until.bev.callbacks, (ev)->stop_simulation(ev, env))
  try
    while true
      step(env)
    end
  catch exc
    if isa(exc, StopSimulation)
      return exc.value
    elseif isa(exc, EmptySchedule)
      return nothing
    else
      rethrow(exc)
    end
  end
end

function stop_simulation(env::AbstractEnvironment, value=nothing)
  throw(StopSimulation(value))
end

function stop_simulation(ev::AbstractEvent, env::AbstractEnvironment)
  stop_simulation(env, ev.bev.value)
end

function triggered(ev::AbstractEvent)
  return ev.bev.state == EVENT_TRIGGERED
end

function processed(ev::AbstractEvent)
  return ev.bev.state == EVENT_PROCESSED
end

function value(ev::AbstractEvent)
  return ev.bev.value
end

function append_callback(ev::AbstractEvent, callback::Function, args...)
  if ev.bev.state == EVENT_PROCESSED
    throw(EventProcessed())
  end
  push!(ev.bev.callbacks, (ev)->callback(ev, args...))
end

function succeed(ev::AbstractEvent, value=nothing)
  if ev.bev.state > EVENT_INITIAL
    throw(EventTriggered())
  end
  schedule(ev, value)
  return ev
end

function fail(ev::AbstractEvent, exc::Exception)
  if ev.bev.state > EVENT_INITIAL
    throw(EventTriggered())
  end
  schedule(ev, exc)
  return ev
end

function trigger(cause::AbstractEvent, ev::AbstractEvent)
  if ev.bev.state > EVENT_INITIAL
    throw(EventTriggered())
  end
  schedule(ev, cause.bev.value)
  return ev
end

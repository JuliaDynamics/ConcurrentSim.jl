type StopEnvironment <: Exception
  value :: Any
end

type EventProcessing <: Exception end

"""
Parent type for event processing environments.

An implementation must at least provide the means to access the current time of the environment (see ``now``), to process events (see ``step``) and to give a reference to the active process (see ``active_process``).

The class is meant to be subclassed for different execution environments. For example, SimJulia defines a :class:`Simulation` for simulations with a virtual time.
"""
abstract Environment

type Event
  id :: UInt
  env :: Environment
  callbacks :: Vector{Function}
  processing :: Bool
  value :: Any
  function Event(env::Environment)
    ev = new()
    ev.id = env.eid += 1
    ev.env = env
    ev.callbacks = Function[]
    ev.processing = false
    ev.value = nothing
    return ev
  end
end

function run(env::Environment, until::Event)
  append_callback(stop_environment, until)
  try
    while step(env) end
    return nothing
  catch exc
    if isa(exc, StopEnvironment)
      return exc.value
    else
      rethrow(exc)
    end
  end
end

function run(env::Environment, until::Float64)
  ev = Event(env)
  schedule(env, ev, until)
  run(env, ev)
end

function run(env::Environment)
  ev = Event(env)
  run(env, ev)
end

function stop_environment(ev::Event)
  throw(StopEnvironment(ev.value))
end

function append_callback(cb::Function, ev::Event, args...)
  if ev.processing
    throw(EventProcessing())
  end
  push!(ev.callbacks, (ev)->cb(ev, args...))
end

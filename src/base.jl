abstract type AbstractEvent end
abstract type Environment end

@enum EVENT_STATE idle=0 scheduled=1 processed=2

struct EventProcessed <: Exception
  ev :: AbstractEvent
end

struct EventNotIdle <: Exception
  ev :: AbstractEvent
end

"""An unfinished event lost its last subscriber and cannot be reused. Create a fresh event."""
struct EventAbandoned <: Exception
  ev :: AbstractEvent
end

function Base.showerror(io::IO, exc::EventAbandoned)
  print(io, "Event abandoned: ", exc.ev, ". Create a fresh event instead of reusing this wait.")
end

mutable struct BaseEvent
  env :: Environment
  id :: UInt
  callbacks :: Vector{Function}
  state :: EVENT_STATE
  value :: Any
  abandoned :: Bool
  function BaseEvent(env::Environment)
    new(env, env.eid+=one(UInt), Vector{Function}(), idle, nothing, false)
  end
end

"""
    abandon_on_unobserved(event::AbstractEvent)

Return whether an unfinished event should be abandoned when its last subscriber
is removed. The default is `false`; custom wait events can opt in by returning
`true` and implementing [`on_abandon`](@ref). An abandoned event cannot be
scheduled, subscribed to, or yielded again, even after its queued event is processed.
"""
abandon_on_unobserved(::AbstractEvent) = false

"""
    on_abandon(event::AbstractEvent)

Release registrations owned by an event that opted into [`abandon_on_unobserved`](@ref).
Called once, after the event is marked abandoned. The default does nothing.
Cleanup must not resume the event or mutate a callback vector being dispatched.
"""
on_abandon(::AbstractEvent) = nothing

has_subscribers(ev::AbstractEvent) = !isempty(ev.bev.callbacks)

function check_not_abandoned(ev::AbstractEvent)
  ev.bev.abandoned && throw(EventAbandoned(ev))
  nothing
end

function show(io::IO, ev::AbstractEvent)
  print(io, "$(typeof(ev)) $(ev.bev.id)")
end

function show(io::IO, env::Environment)
  if env.active_proc === nothing
    print(io, "$(typeof(env)) time: $(now(env)) active_process: nothing")
  else
    print(io, "$(typeof(env)) time: $(now(env)) active_process: $(env.active_proc)")
  end
end

function environment(ev::AbstractEvent) :: Environment
  ev.bev.env
end

function value(ev::AbstractEvent) :: Any
  ev.bev.value
end

function state(ev::AbstractEvent) :: EVENT_STATE
  ev.bev.state
end

function append_callback(func::Function, ev::AbstractEvent, args::Any...) :: Function
  check_not_abandoned(ev)
  ev.bev.state === processed && throw(EventProcessed(ev))
  cb = ()->func(ev, args...)
  push!(ev.bev.callbacks, cb)
  cb
end

macro callback(expr::Expr)
  expr.head !== :call && error("Expression is not a function call!")
  esc(:(ConcurrentSim.append_callback($(expr.args...))))
end

function remove_callback(cb::Function, ev::AbstractEvent)
  # Processed callbacks may still be dispatching. They are no longer subscribers.
  state(ev) === processed && return nothing
  i = findfirst(x -> x == cb, ev.bev.callbacks)
  i === nothing && return nothing
  deleteat!(ev.bev.callbacks, i)
  if !ev.bev.abandoned && abandon_on_unobserved(ev) && !has_subscribers(ev)
    ev.bev.abandoned = true
    on_abandon(ev)
  end
  nothing
end

function schedule(ev::AbstractEvent, delay::Number=0; priority=0, value=nothing)
  check_not_abandoned(ev)
  state(ev) === processed && throw(EventProcessed(ev))
  env = environment(ev)
  bev = ev.bev
  bev.value = value
  env.heap[bev] = EventKey(now(env) + delay, Int(priority), env.sid+=one(UInt))
  bev.state = scheduled
  ev
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

function run(env::Environment, until::AbstractEvent)
  @callback stop_simulation(until)
  try
    while true
      step(env)
    end
  catch exc
    if isa(exc, StopSimulation)
      return exc.value
    else
      rethrow(exc)
    end
  end
end

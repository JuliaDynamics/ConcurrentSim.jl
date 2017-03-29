abstract type AbstractEvent end
abstract type Environment end

@enum EVENT_STATE idle=0 scheduled=1 triggered=2

struct EventTriggered <: Exception
  ev :: AbstractEvent
end

struct EventNotIdle <: Exception
  ev :: AbstractEvent
end

mutable struct BaseEvent
  env :: Environment
  id :: UInt
  callbacks :: Vector{Function}
  state :: EVENT_STATE
  value :: Any
  function BaseEvent(env::Environment)
    new(env, env.eid+=one(UInt), Vector{Function}(), idle, nothing)
  end
end

function show(io::IO, ev::AbstractEvent)
  print(io, "$(typeof(ev)) $(ev.bev.id)")
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
  ev.bev.state == triggered && throw(EventTriggered(ev))
  cb = ()->func(ev, args...)
  push!(ev.bev.callbacks, cb)
  cb
end

macro callback(expr::Expr)
  expr.head != :call && error("Expression is not a function call!")
  func = esc(expr.args[1])
  args = [esc(expr.args[n]) for n in 2:length(expr.args)]
  :(append_callback($(func), $(args...)))
end

function remove_callback(cb::Function, ev::AbstractEvent)
  i = indexin(ev.bev.callbacks, [cb])[1]
  deleteat!(ev.bev.callbacks, i)
end

function schedule(ev::AbstractEvent, delay::Number=zero(Float64); priority::Int8=zero(Int8), value::Any=nothing)
  env = environment(ev)
  bev = ev.bev
  bev.value = value
  env.heap[bev] = EventKey(now(env) + delay, priority, env.sid+=one(UInt))
  bev.state = scheduled
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

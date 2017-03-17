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
  cid :: UInt
  callbacks :: DataStructures.PriorityQueue{Function, UInt}
  state :: EVENT_STATE
  value :: Any
  function BaseEvent(env::Environment)
    new(env, env.eid+=one(UInt), zero(UInt), DataStructures.PriorityQueue(Function, UInt), idle, nothing)
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
  ev.bev.callbacks[cb] = ev.bev.cid+=one(UInt)
  cb
end

macro callback(expr::Expr)
  expr.head != :call && error("Expression is not a function call!")
  func = esc(expr.args[1])
  args = [esc(expr.args[n]) for n in 2:length(expr.args)]
  :(append_callback($(func), $(args...)))
end

function remove_callback(cb::Function, ev::AbstractEvent)
  DataStructures.dequeue!(ev.bev.callbacks, cb)
end

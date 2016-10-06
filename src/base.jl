abstract Environment
abstract AbstractEvent

@enum EVENT_STATE idle=0 triggered=1 processed=2

type EventProcessed <: Exception end
type EventNotIdle <: Exception end

type BaseEvent{E<:Environment}
  env :: E
  id :: UInt
  cid :: UInt
  callbacks :: PriorityQueue{Function, UInt}
  state :: EVENT_STATE
  value :: Any
  function BaseEvent(env::E)
    new(env, env.eid+=one(UInt), zero(UInt), PriorityQueue(Function, UInt), idle, nothing)
  end
end

function BaseEvent{E<:Environment}(env::E) :: BaseEvent
  BaseEvent{E}(env)
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
  if ev.bev.state == processed
    throw(EventProcessed())
  end
  cb = ()->func(ev, args...)
  ev.bev.callbacks[cb] = ev.bev.cid+=one(UInt)
  return cb
end

function remove_callback(cb::Function, ev::AbstractEvent)
  dequeue!(ev.bev.callbacks, cb)
end

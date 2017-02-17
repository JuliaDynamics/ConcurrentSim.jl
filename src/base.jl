using Compat

@compat abstract type Environment end

"""
The parent type for all events.

An events holds a pointer to an instance of a subtype of `Environment`.

An event has a state:

- may happen (idle),
- is going to happen (scheduled),
- has happened (triggered).

Once the events is scheduled, it has a value.

An event has also a list of callbacks. A callback can be any function as long as it accepts an instance of a subtype of `AbstractEvent` as its first argument. Once an event gets triggered, all callbacks will be invoked. Callbacks can do further processing with the value it has produced.
"""
@compat abstract type AbstractEvent{E<:Environment} end

@enum EVENT_STATE idle=0 scheduled=1 triggered=2

immutable EventTriggered{E<:Environment} <: Exception
  ev :: AbstractEvent{E}
end

immutable EventNotIdle{E<:Environment} <: Exception
  ev :: AbstractEvent{E}
end

type BaseEvent{E<:Environment}
  env :: E
  id :: UInt
  cid :: UInt
  callbacks :: DataStructures.PriorityQueue{Function, UInt}
  state :: EVENT_STATE
  value :: Any
  function BaseEvent(env::E)
    new(env, env.eid+=one(UInt), zero(UInt), DataStructures.PriorityQueue(Function, UInt), idle, nothing)
  end
end

function BaseEvent{E<:Environment}(env::E) :: BaseEvent
  BaseEvent{E}(env)
end

  # type BaseEvent{E<:Environment}
  #   env :: E
  #   id :: UInt
  #   cid :: UInt
  #   callbacks :: DataStructures.PriorityQueue{Function, UInt}
  #   state :: EVENT_STATE
  #   value :: Any
  #   function BaseEvent{E}(env::E) where E<:Environment
  #     new(env, env.eid+=one(UInt), zero(UInt), DataStructures.PriorityQueue(Function, UInt), idle, nothing)
  #   end
  # end

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
  if ev.bev.state == triggered
    throw(EventTriggered(ev))
  end
  cb = ()->func(ev, args...)
  ev.bev.callbacks[cb] = ev.bev.cid+=one(UInt)
  return cb
end

function remove_callback(cb::Function, ev::AbstractEvent)
  DataStructures.dequeue!(ev.bev.callbacks, cb)
end

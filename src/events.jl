struct Event{E<:Environment} <: AbstractEvent{E}
  bev :: BaseEvent{E}
  function Event{E}(env::E) where E<:Environment
    new(BaseEvent(env))
  end
end

function Event{E<:Environment}(env::E)
  Event{E}(env)
end

function succeed{E<:Environment}(ev::Event{E}; priority::Int8=Int8(0), value::Any=nothing) :: Event{E}
  sta = state(ev)
  (sta == scheduled || sta == triggered) && throw(EventNotIdle(ev))
  schedule(ev.bev, priority=priority, value=value)
  return ev
end

function fail{E<:Environment}(ev::Event{E}, exc::Exception; priority::Int8=Int8(0)) :: Event{E}
  succeed(ev, priority=priority, value=exc)
end

"""
An event that gets triggered after a delay has passed.

This event is automatically scheduled when it is created.

**Signature**:

Timeout{E<:Environment} <: AbstractEvent{E}

**Field**:

- bev :: BaseEvent{E}

**Constructors**:

- Timeout{E<:Environment}(env::E, delay::Period; priority::Bool=false, value::Any=nothing)
- Timeout{E<:Environment}(env::E, delay::Number=0; priority::Bool=false, value::Any=nothing)
"""

struct Timeout{E<:Environment} <: AbstractEvent{E}
  bev :: BaseEvent{E}
  function Timeout{E}(env::E, delay::Union{Period, Number}, priority::Int8, value::Any) where E<:Environment
    ev = new(BaseEvent(env))
    schedule(ev.bev, delay, priority=priority, value=value)
    return ev
  end
end

function Timeout{E<:Environment}(env::E, delay::Period; priority::Int8=Int8(0), value::Any=nothing) :: Timeout{E}
  Timeout{E}(env, delay, priority, value)
end

function Timeout{E<:Environment}(env::E, delay::Number=0; priority::Int8=Int8(0), value::Any=nothing) :: Timeout{E}
  Timeout{E}(env, delay, priority, value)
end

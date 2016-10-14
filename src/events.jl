type Event{E<:Environment} <: AbstractEvent{E}
  bev :: BaseEvent{E}
  function Event(env::E)
    new(BaseEvent(env))
  end
end

function Event{E<:Environment}(env::E) :: Event{E}
  Event{E}(env)
end

function succeed{E<:Environment}(ev::Event{E}; priority::Bool=false, value::Any=nothing) :: Event{E}
  sta = state(ev)
  if sta == triggered || sta == processed
    throw(EventNotIdle(ev))
  end
  schedule(ev.bev, priority=priority, value=value)
  return ev
end

function fail{E<:Environment}(ev::Event{E}, exc::Exception; priority::Bool=false) :: Event{E}
  succeed(ev, priority=priority, value=exc)
end

type Timeout{E<:Environment} <: AbstractEvent{E}
  bev :: BaseEvent{E}
  function Timeout(env::E, delay::Union{Period, Number}, priority::Bool, value::Any)
    ev = new(BaseEvent(env))
    schedule(ev.bev, delay, priority=priority, value=value)
    return ev
  end
end

"""
Returns an event that gets triggered after a delay has passed.

This event is automatically scheduled when it is created.

**Methods**:

- `timeout{E<:Environment}(env::E, delay::Period; priority::Bool=false, value::Any=nothing) :: Timeout{E}`
- `timeout{E<:Environment}(env::E, delay::Number=0; priority::Bool=false, value::Any=nothing) :: Timeout{E}`
"""
function timeout{E<:Environment}(env::E, delay::Period; priority::Bool=false, value::Any=nothing) :: Timeout{E}
  Timeout{E}(env, delay, priority, value)
end

function timeout{E<:Environment}(env::E, delay::Number=0; priority::Bool=false, value::Any=nothing) :: Timeout{E}
  Timeout{E}(env, delay, priority, value)
end

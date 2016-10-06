type Event{E<:Environment} <: AbstractEvent
  bev :: BaseEvent{E}
  function Event(env::E)
    new(BaseEvent(env))
  end
end

function Event{E<:Environment}(env::E) :: Event{E}
  Event{E}(env)
end

function succeed(ev::Event; priority::Bool=false, value::Any=nothing) :: Event
  if ev.bev.state == triggered || ev.bev.state == processed
    throw(EventNotIdle())
  end
  schedule(ev.bev, priority=priority, value=value)
  return ev
end

function fail(ev::Event, exc::Exception; priority::Bool=false) :: Event
  succeed(ev, priority=priority, value=exc)
end

type Timeout{E<:Environment} <: AbstractEvent
  bev :: BaseEvent{E}
  function Timeout(env::E, delay::Union{Period, Number}, priority::Bool, value::Any)
    ev = new(BaseEvent(env))
    schedule(ev.bev, delay, priority=priority, value=value)
    return ev
  end
end

function timeout{E<:Environment}(env::E, delay::Period; priority::Bool=false, value::Any=nothing) :: Timeout{E}
  Timeout{E}(env, delay, priority, value)
end

function timeout{E<:Environment}(env::E, delay::Number=0; priority::Bool=false, value::Any=nothing) :: Timeout{E}
  Timeout{E}(env, delay, priority, value)
end

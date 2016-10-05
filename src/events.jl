type Event{E<:Environment} <: AbstractEvent
  bev :: BaseEvent{E}
  function Event(env::E)
    ev = new()
    ev.bev = BaseEvent(env)
    return ev
  end
end

function Event{E<:Environment}(env::E) :: Event{E}
  Event{E}(env)
end

function succeed(ev::Event; priority::Bool=false, value::Any=nothing) :: Event
  if ev.bev.state == processed
    throw(EventProcessed())
  end
  schedule(ev.bev, priority=priority, value=value)
  return ev
end

function fail(ev::Event, exc::Exception; priority::Bool=false) :: Event
  if ev.bev.state == processed
    throw(EventProcessed())
  end
  schedule(ev.bev, priority=priority, value=exc)
  return ev
end

type Timeout{E<:Environment} <: AbstractEvent
  bev :: BaseEvent{E}
  function Timeout(env::E, delay::Period, priority::Bool, value::Any)
    ev = new()
    ev.bev = BaseEvent(env)
    schedule(ev.bev, delay, priority=priority, value=value)
    return ev
  end
end

function Timeout{E<:Environment}(env::E, delay::Period; priority::Bool=false, value::Any=nothing) :: Timeout{E}
  Timeout{E}(env, delay, priority, value)
end

function Timeout{E<:Environment}(env::E, delay::Number=0; priority::Bool=false, value::Any=nothing) :: Timeout{E}
  Timeout{E}(env, eps(env.time)*delay, priority, value)
end

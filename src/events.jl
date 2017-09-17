struct Event <: AbstractEvent
  bev :: BaseEvent
  function Event(env::Environment)
    new(BaseEvent(env))
  end
end

function succeed(ev::Event; priority::Int8=zero(Int8), value::Any=nothing) :: Event
  state(ev) != idle && throw(EventNotIdle(ev))
  schedule(ev; priority=priority, value=value)
end

function fail(ev::Event, exc::Exception; priority::Int8=zero(Int8)) :: Event
  succeed(ev; priority=priority, value=exc)
end

struct Timeout <: AbstractEvent
  bev :: BaseEvent
  function Timeout(env::Environment, delay::Number=0; priority::Int8=zero(Int8), value::Any=nothing)
    schedule(new(BaseEvent(env)), delay; priority=priority, value=value)
  end
end

function run(env::Environment, until::Number=typemax(Float64))
  run(env, Timeout(env, until-now(env)))
end

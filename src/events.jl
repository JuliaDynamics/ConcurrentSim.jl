struct Event <: AbstractEvent
  bev :: BaseEvent
  function Event(env::Environment)
    new(BaseEvent(env))
  end
end

function succeed(ev::Event; priority=0, value=nothing) :: Event
  state(ev) !== idle && throw(EventNotIdle(ev))
  schedule(ev; priority=Int(priority), value)
end

function fail(ev::Event, exc::Exception; priority=0) :: Event
  succeed(ev; priority=Int(priority), value=exc)
end

struct Timeout <: AbstractEvent
  bev :: BaseEvent
  function Timeout(env::Environment)
    new(BaseEvent(env))
  end
end

function timeout(env::Environment, delay::Number=0; priority=0, value::Any=nothing)
  schedule(Timeout(env), delay; priority=Int(priority), value)
end

function run(env::Environment, until::Number=Inf)
  run(env, timeout(env, until-now(env)))
end

struct Event <: AbstractEvent
    bev::BaseEvent
    function Event(env::Environment)
        new(BaseEvent(env))
    end
end

function succeed(ev::Event; priority::Int=0, value::Any=nothing)::Event
    state(ev) !== idle && throw(EventNotIdle(ev))
    schedule(ev; priority=priority, value=value)
end

function fail(ev::Event, exc::Exception; priority::Int=0)::Event
    succeed(ev; priority=priority, value=exc)
end

struct Timeout <: AbstractEvent
    bev::BaseEvent
    function Timeout(env::Environment)
        new(BaseEvent(env))
    end
end

function timeout(env::Environment, delay::Number=0; priority::Int=0, value::Any=nothing)
    schedule(Timeout(env), delay; priority=priority, value=value)
end

function run(env::Environment, until::Number=typemax(Float64))
    run(env, timeout(env, until - now(env)))
end

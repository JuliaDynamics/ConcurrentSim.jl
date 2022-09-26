abstract type AbstractEvent end
abstract type Environment end

@enum EVENT_STATE idle = 0 scheduled = 1 processed = 2

struct EventProcessed <: Exception
    ev::AbstractEvent
end

struct EventNotIdle <: Exception
    ev::AbstractEvent
end

mutable struct BaseEvent
    env::Environment
    id::UInt
    callbacks::Vector{Function}
    state::EVENT_STATE
    value::Any
    function BaseEvent(env::Environment)
        new(env, env.eid += one(UInt), Vector{Function}(), idle, nothing)
    end
end

function show(io::IO, ev::AbstractEvent)
    print(io, "$(typeof(ev)) $(ev.bev.id)")
end

function show(io::IO, env::Environment)
    if env.active_proc === nothing
        print(io, "$(typeof(env)) time: $(now(env)) active_process: nothing")
    else
        print(io, "$(typeof(env)) time: $(now(env)) active_process: $(env.active_proc)")
    end
end

function environment(ev::AbstractEvent)::Environment
    ev.bev.env
end

function value(ev::AbstractEvent)::Any
    ev.bev.value
end

function state(ev::AbstractEvent)::EVENT_STATE
    ev.bev.state
end

function append_callback(func::Function, ev::AbstractEvent, args::Any...)::Function
    ev.bev.state === processed && throw(EventProcessed(ev))
    cb = () -> func(ev, args...)
    push!(ev.bev.callbacks, cb)
    cb
end

macro callback(expr::Expr)
    expr.head !== :call && error("Expression is not a function call!")
    esc(:(SimJulia.append_callback($(expr.args...))))
end

function remove_callback(cb::Function, ev::AbstractEvent)
    i = findfirst(x -> x == cb, ev.bev.callbacks)
    i != 0 && deleteat!(ev.bev.callbacks, i)
end

function schedule(ev::AbstractEvent, delay::Number=zero(Float64); priority::Int=0, value::Any=nothing)
    state(ev) === processed && throw(EventProcessed(ev))
    env = environment(ev)
    bev = ev.bev
    bev.value = value
    env.heap[bev] = EventKey(now(env) + delay, priority, env.sid += one(UInt))
    bev.state = scheduled
    ev
end

struct StopSimulation <: Exception
    value::Any
    function StopSimulation(value::Any=nothing)
        new(value)
    end
end

function stop_simulation(ev::AbstractEvent)
    throw(StopSimulation(value(ev)))
end

function run(env::Environment, until::AbstractEvent)
    @callback stop_simulation(until)
    try
        while true
            step(env)
        end
    catch exc
        if isa(exc, StopSimulation)
            return exc.value
        else
            rethrow(exc)
        end
    end
end

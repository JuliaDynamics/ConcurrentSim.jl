using SimJulia
using Base.Collections

import Base.schedule, Base.run

type ConcreteEnvironment <: SimJulia.Environment
  heap :: Vector{SimJulia.BaseEvent{ConcreteEnvironment}}
  eid :: UInt
  function ConcreteEnvironment()
    cenv = new()
    cenv.heap = SimJulia.BaseEvent[]
    cenv.eid = zero(UInt)
    return cenv
  end
end

function schedule(bev::SimJulia.BaseEvent{ConcreteEnvironment}, delay::Number=0; priority::Bool=false, value::Any=nothing)
  bev.value = value
  bev.state = SimJulia.triggered
  push!(bev.env.heap, bev)
  println("Event is scheduled with delay $delay, priority $priority and value $value")
end

function run(cenv::ConcreteEnvironment)
  for bev in cenv.heap
    bev.state = SimJulia.processed
    while !isempty(bev.callbacks)
      cb = dequeue!(bev.callbacks)
      cb()
    end
  end
end

type ConcreteEvent{E<:SimJulia.Environment} <: SimJulia.AbstractEvent
  bev :: SimJulia.BaseEvent
  function ConcreteEvent(env::E)
    ev = new()
    ev.bev = SimJulia.BaseEvent(env)
    return ev
  end
end

function ConcreteEvent{E<:SimJulia.Environment}(env::E)
  ConcreteEvent{E}(env)
end

function test_callback(ev::ConcreteEvent)
  println("I am callback function running in $(typeof(environment(ev)))")
end

cenv = ConcreteEnvironment()
ev = ConcreteEvent(cenv)
cb = append_callback(test_callback, ev)
remove_callback(cb, ev)
println(state(ev))
println(value(ev))
schedule(ev.bev, value="Hi")
append_callback(test_callback, ev)
println(state(ev))
println(value(ev))
run(cenv)
try
  append_callback(test_callback, ev)
catch exc
  println("$exc has been thrown")
end
println(state(ev))
println(value(ev))

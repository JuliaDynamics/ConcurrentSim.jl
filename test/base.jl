using ConcurrentSim

function test_callback(ev::Event)
  println("I am a callback function running in $(typeof(environment(ev)))")
end

sim = Simulation()
ev = Event(sim)
println(typeof(ev))
cb = @callback test_callback(ev)
remove_callback(cb, ev)
println(state(ev))
show(value(ev))
println()
succeed(ev, value="Hi")
@callback test_callback(ev)
println(state(ev))
println(value(ev))
run(sim)
try
  @callback test_callback(ev)
catch exc
  println("$exc has been thrown!")
end
println(state(ev))
println(value(ev))

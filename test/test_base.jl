using SimJulia

function test_callback(ev::Event)
  println("I am callback function running in $(typeof(environment(ev)))")
end

sim = Simulation()
ev = Event(sim)
println(typeof(ev))
cb = append_callback(test_callback, ev)
remove_callback(cb, ev)
println(state(ev))
println(value(ev))
succeed(ev, value="Hi")
append_callback(test_callback, ev)
println(state(ev))
println(value(ev))
run(sim)
try
  append_callback(test_callback, ev)
catch exc
  println("$exc has been thrown")
end
println(state(ev))
println(value(ev))

using SimJulia
using Base.Dates

function test_callback(ev::AbstractEvent)
  println("Hi I timed out at $(now(environment(ev)))")
end

function test_callback_exception(ev::Event)
  throw(TestException())
end

sim = Simulation(now())
append_callback(test_callback, Timeout(sim, Day(1)))
append_callback(test_callback, Timeout(sim, 3600000))
run(sim, Day(2))
sim = Simulation()
try
  run(sim, Event(sim))
catch exc
  println("$exc has been thrown")
end
sim = Simulation(now())
start = now()
append_callback(test_callback, Timeout(sim, Day(1)))
run(sim, start+Day(2))
println(now(sim)-start)
sim = Simulation()
start = now(sim)
ev = Event(sim)
append_callback(test_callback_exception, ev)
succeed(ev)
try
  run(sim)
catch exc
  println("$exc has been thrown after $(now(sim)-start)")
end

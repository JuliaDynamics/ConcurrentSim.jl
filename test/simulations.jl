using Simulvent

struct TestException <: Exception end

function test_callback(ev::AbstractEvent)
  println("Hi I timed out at $(now(ev))")
end

function test_callback_exception(ev::Event)
  throw(TestException())
end

sim = Simulation()
@callback test_callback(timeout(sim, 1))
@callback test_callback(timeout(sim, 3))
run(sim, 2)
sim = Simulation()
try
  run(sim, Event(sim))
catch exc
  println("$exc has been thrown!")
end
sim = Simulation(3)
start_time = now(sim)
@callback test_callback(timeout(sim, 1))
run(sim, start_time+2)
println(now(sim)-start_time)
sim = Simulation()
start_time = now(sim)
ev = Event(sim)
@callback test_callback_exception(ev)
succeed(ev)
try
  run(sim)
catch exc
  println("$exc has been thrown after $(now(sim)-start_time)!")
end

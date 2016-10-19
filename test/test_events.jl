using SimJulia

type TestException <: Exception end

function test_callback_event(ev::Event)
  println("Hi $ev has value $(value(ev))")
end

function test_callback_Timeout(ev::AbstractEvent)
  println("Hi $ev timed out at $(now(environment(ev)))")
end

sim = Simulation()
ev1 = Event(sim)
append_callback(test_callback_event, ev1)
succeed(ev1, value="Succes")
ev2 = Event(sim)
append_callback(test_callback_event, ev2)
fail(ev2, TestException())
try
  succeed(ev2)
catch exc
  println("$exc has been thrown")
end
append_callback(test_callback_Timeout, Timeout(sim, 1))
run(sim)

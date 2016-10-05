using SimJulia

type TestException <: Exception end

function test_callback_event(ev::Event)
  println("Hi $ev have value $(value(ev))")
end

function test_callback_timeout(ev::Timeout)
  println("Hi $ev timed out at $(now(environment(ev)))")
end

sim = Simulation()
ev1 = Event(sim)
append_callback(test_callback_event, ev1)
succeed(ev1, value="Succes")
ev2 = Event(sim)
append_callback(test_callback_event, ev2)
fail(ev2, TestException())
ev3 = Timeout(sim, 1)
append_callback(test_callback_timeout, ev3)
run(sim)

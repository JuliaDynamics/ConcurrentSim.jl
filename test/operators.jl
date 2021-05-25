using SimJulia

function and_callback(ev::AbstractEvent)
  println("Both events are triggered: $(value(ev))")
end

function or_callback(ev::AbstractEvent)
  println("One of both events is triggered: $(value(ev))")
end

function or_callback_succeed(ev::AbstractEvent, ev2::AbstractEvent)
  println("One of both events is triggered: $(value(ev))")
  succeed(ev2)
end

function or_callback_fail(ev::AbstractEvent, ev2::AbstractEvent)
  println("One of both events is triggered: $(value(ev))")
  fail(ev2, TestException())
end

sim = Simulation()
ev1 = timeout(sim, 1)
ev2 = Event(sim)
@callback and_callback(ev1 & ev2)
@callback or_callback_succeed(ev1 | ev2, ev2)
run(sim)

sim = Simulation()
ev1 = timeout(sim, 1, value=TestException())
ev2 = Event(sim)
@callback or_callback_fail(ev1 | ev2, ev2)
@callback and_callback(ev1 & ev2)
run(sim)

sim = Simulation()
ev1 = timeout(sim)
ev2 = timeout(sim, value=TestException())
@callback or_callback(ev1 | ev2)
run(sim)

sim = Simulation()
ev1 = timeout(sim)
ev2 = timeout(sim)
@callback or_callback(ev1 | ev2)
run(sim)

sim = Simulation()
ev1 = timeout(sim, 1)
ev2 = Event(sim)
ev3 = timeout(sim, 2)
@callback and_callback(AllOf(ev1, ev2, ev3))
@callback or_callback_succeed(AnyOf(ev1, ev2, ev3), ev2)
run(sim)

sim = Simulation()
ev1 = timeout(sim, 1, value=TestException())
ev2 = Event(sim)
ev3 = Event(sim)
@callback or_callback_fail(AnyOf(ev1, ev2, ev3), ev2)
@callback and_callback(AllOf(ev1, ev2, ev3))
run(sim)

sim = Simulation()
ev1 = timeout(sim)
ev2 = timeout(sim, value=TestException())
ev3 = timeout(sim)
@callback or_callback(AnyOf(ev1, ev2, ev3))
run(sim)

sim = Simulation()
ev1 = timeout(sim)
ev2 = timeout(sim)
ev3 = timeout(sim)
@callback or_callback(AnyOf(ev1, ev2, ev3))
run(sim)

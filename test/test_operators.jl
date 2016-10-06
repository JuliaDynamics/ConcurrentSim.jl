using SimJulia

function and_callback(ev::AbstractEvent)
  println("Both events are triggered")
end

function or_callback(ev::AbstractEvent, ev2::Event)
  println("One of both events is triggered")
  succeed(ev2)
end

sim = Simulation()
ev1 = timeout(sim, 1)
ev2 = Event(sim)
append_callback(and_callback, ev1 & ev2)
append_callback(or_callback, ev1 | ev2, ev2)
run(sim)

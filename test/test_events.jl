using SimJulia

function test_cb(ev::Event, sim::Simulation)
  println("Hi, it's now $(now(sim)) time units after start of simulation")
end

function test_another_cb(ev::Event)
  println("Hi, I am a second callback")
end

sim = Simulation()
ev = Event(sim)
append_callback(test_cb, ev, sim)
schedule(sim, ev, 1.0)
another_ev = Event(sim)
append_callback(test_cb, another_ev, sim)
append_callback(test_another_cb, another_ev)
schedule(sim, another_ev, 2.0)
run(sim)

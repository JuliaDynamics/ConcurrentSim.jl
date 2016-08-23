using SimJulia
using Base.Dates

function test_cb(sim::Simulation)
  println("Hi, it's now $(now(sim))")
end

function test_another_cb(sim::Simulation)
  println("Hi, I am a second callback")
end

function and_cb(sim::Simulation)
  println("Both events are triggered!")
end

sim = Simulation(now())
ev = Event()
append_callback(ev, test_cb)
schedule(sim, ev, Day(1))
another_ev = Event(sim, 3600000*24*2)
append_callback(another_ev, test_cb)
and_event = ev & another_ev
append_callback(and_event, and_cb)
append_callback(and_event, test_another_cb)
run(sim)

sim = Simulation()
ev = Event()
append_callback(ev, test_cb)
schedule(sim, ev, 1)
another_ev = Event(sim, 2)
append_callback(another_ev, test_cb)
and_event = ev & another_ev
append_callback(and_event, and_cb)
append_callback(and_event, test_another_cb)
run(sim)

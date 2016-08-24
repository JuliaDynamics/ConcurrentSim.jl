using SimJulia
using Base.Dates

type TestException <: Exception end

function test_cb(sim::Simulation, ev::Event)
  println(value(ev))
  println("$(now()): Hi, it's now $(now(sim))")
end

function test_another_cb(sim::Simulation)
  println("$(now()): Hi, I am a second callback")
end

function and_cb(sim::Simulation, ev)
  if isa(value(ev), Exception)
    println("Exception has been thrown!")
  else
    println("$(now()): Both events are triggered!")
    println(value(ev))
  end
end

function or_cb(sim::Simulation)
  println("$(now()): One of both events is triggered!")
  println(value(ev))
end

sim = Simulation(now())
ev = Event()
append_callback(ev, test_cb, ev)
schedule(sim, ev, Day(1))
another_ev = Event(sim, 3600000*24*2)
schedule!(sim, ev, Hour(23), value=TestException())
append_callback(another_ev, test_cb, another_ev)
and_event = ev & another_ev
append_callback(and_event, and_cb, and_event)
append_callback(and_event, test_another_cb)
run(sim)

sim = Simulation()
ev = Event()
append_callback(ev, test_cb, ev)
schedule(sim, ev, 1)
another_ev = Event(sim, 3, value="π-day0314")
append_callback(another_ev, test_cb, another_ev)
or_event = ev | another_ev
append_callback(or_event, or_cb)
append_callback(or_event, test_another_cb)
run(sim)

sim = Simulation(today())
ev = Event()
append_callback(ev, test_cb, ev)
schedule(sim, ev, 1)
another_ev = Event(sim, Month(2))
append_callback(another_ev, test_cb, another_ev)
and_event = ev & another_ev
append_callback(and_event, and_cb, and_event)
append_callback(and_event, test_another_cb)
run(sim, 5)

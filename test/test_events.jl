using SimJulia
using Base.Dates

type TestException <: Exception end

function test_cb(sim::Simulation, ev::Event)
  println(value(ev))
  println("$(now()): Hi, it's now $(now(sim))")
end

function test_another_cb(sim::Simulation, ev::Event)
  println("$(now()): Hi, I am a second callback at $(now(sim))")
end

function and_cb(sim::Simulation, ev::Event)
  if isa(value(ev), Exception)
    println("Exception has been thrown!")
  else
    println("$(now()): Both events are triggered at $(now(sim))!")
    println(value(ev))
  end
end

function or_cb(sim::Simulation, ev::Event)
  println("$(now()): One of both events is triggered at $(now(sim))!")
  println(value(ev))
  println(state(ev))
end

sim = Simulation(now())
ev = Event()
append_callback(ev, test_cb)
schedule(sim, ev, Day(1))
another_ev = Event(sim, 3600000*24*2)
schedule!(sim, ev, Hour(23), value=TestException())
append_callback(another_ev, test_cb)
and_event = ev & another_ev
append_callback(and_event, and_cb)
append_callback(and_event, test_another_cb)
run(sim, Month(1))

sim = Simulation()
ev = Event()
append_callback(ev, test_cb)
schedule(sim, ev, 1)
another_ev = Event(sim, 3, value="π-day0314")
append_callback(another_ev, test_cb)
or_event = ev | another_ev
append_callback(or_event, or_cb)
append_callback(or_event, test_another_cb)
run(sim)

sim = Simulation(today())
ev = Event()
append_callback(ev, test_cb)
schedule!(sim, ev, 1)
another_ev = Event(sim, Month(2))
append_callback(another_ev, test_cb)
and_event = ev & another_ev
append_callback(and_event, and_cb)
append_callback(and_event, test_another_cb)
run(sim, today() + Month(1))

function print_cb(sim::Simulation, ev::Event, i::Int)
  println("At time $(now(sim)) event $i is processed")
end

function append_cb(sim::Simulation, ev::Event)
  try
    append_callback(ev, append_cb)
  catch exc
    println(exc)
  end
  try
    schedule(sim, ev)
  catch exc
    println(exc)
  end
  schedule!(sim, ev, 3.5)
end

sim = Simulation(2)
for i = 1:10
  ev = Event(sim, rand())
  append_callback(ev, print_cb, i)
end
Event(sim, 3)
append_callback(ev, append_cb)
try
  run(sim, 4)
catch exc
  println(exc)
end

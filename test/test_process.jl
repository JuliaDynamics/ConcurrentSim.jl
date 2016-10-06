using SimJulia

function fibonnaci(sim::Simulation)
  a = 0
  b = 1
  while true
    println(a)
    yield(timeout(sim, 1))
    a, b = b, a+b
  end
end

function test_process(sim::Simulation, ev::AbstractEvent)
  yield(ev)
end

function test_callback_exception(ev::AbstractEvent)
  println("$(value(ev)) has been thrown")
end

function test_process_exception(sim::Simulation, ev::AbstractEvent)
  try
    value = yield(ev)
    println("hi")
  catch exc
    println("$exc has been thrown")
  end
end

function test_interrupter(sim::Simulation, proc::Process)
  yield(timeout(sim, 2))
  yield(interrupt(proc))
  throw(TestException())
end

function test_interrupted(sim::Simulation)
  try
    yield(timeout(sim, 10))
  catch exc
    if isa(exc, SimJulia.InterruptException)
      println("$(active_process(sim)) interrupted")
    end
  end
  yield(timeout(sim, 10))
end

sim = Simulation()
Process(fibonnaci, sim)
run(sim, 10)

sim = Simulation()
Process(test_process, sim, succeed(Event(sim)))
run(sim)

sim = Simulation()
Process(test_process_exception, sim, timeout(sim, 1, value=TestException()))
try
  run(sim)
catch exc
  println("$exc has been thrown")
end

sim = Simulation()
Process(test_process_exception, sim, timeout(sim, value=TestException()))
run(sim)

sim = Simulation()
proc = Process(test_interrupted, sim)
append_callback(test_callback_exception, Process(test_interrupter, sim, proc))
run(sim)

using SimJulia

function fibonnaci(sim::Simulation)
  a = 0
  b = 1
  while true
    println(a)
    yield(Timeout(sim, 1))
    a, b = b, a+b
  end
end

function test_process(sim::Simulation, ev::AbstractEvent)
  yield(ev)
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
  yield(Timeout(sim, 2))
  yield(Interrupt(proc))
end

function test_interrupted(sim::Simulation)
  try
    yield(Timeout(sim, 10))
  catch exc
    if isa(exc, SimJulia.InterruptException)
      println("$(active_process(sim)) interrupted")
    end
  end
end

sim = Simulation()
Process(fibonnaci, sim)
run(sim, 10)

sim = Simulation()
Process(test_process, sim, succeed(Event(sim)))
run(sim)

sim = Simulation()
Process(test_process_exception, sim, Timeout(sim, 1, value=TestException()))
try
  run(sim)
catch exc
  println("$exc has been thrown")
end

sim = Simulation()
Process(test_process, sim, fail(Event(sim), TestException()))
run(sim)

sim = Simulation()
proc = Process(test_interrupted, sim)
Process(test_interrupter, sim, proc)
run(sim)

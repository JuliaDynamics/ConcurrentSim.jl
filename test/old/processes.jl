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

function test_interrupter(sim::Simulation, proc::OldProcess)
  yield(Timeout(sim, 2))
  interrupt(proc)
end

function test_interrupted(sim::Simulation)
  try
    yield(Timeout(sim, 10))
  catch exc
    if isa(exc, SimJulia.InterruptException)
      println("$(active_process(sim)) interrupted")
    end
  end
  yield(Timeout(sim, 10))
  throw(TestException())
end

sim = Simulation()
@oldprocess fibonnaci(sim)
run(sim, 10)

sim = Simulation()
@oldprocess test_process(sim, succeed(Event(sim)))
run(sim)

sim = Simulation()
@oldprocess test_process_exception(sim, Timeout(sim, 1, value=TestException()))
try
  run(sim)
catch exc
  println("$exc has been thrown")
end

sim = Simulation()
@oldprocess test_process_exception(sim, Timeout(sim, value=TestException()))
run(sim)

sim = Simulation()
proc = @oldprocess test_interrupted(sim)
@oldprocess test_interrupter(sim, proc)
try
  run(sim)
catch exc
  println("$exc has been thrown")
end

function fibonnaci(sim::Simulation)
  a = 0.0
  b = 1.0
  for i = 1:10
    println("Fibonnaci value equals ", a, " at time ", now(sim))
    yield(Timeout(sim, 1.0))
    a, b = b, a+b
  end
  a
end

function wait_for_process(sim::Simulation, process::OldProcess)
  val = yield(process)
  println("Fibonnaci ended with ", val, " at time ", now(sim))
end

sim = Simulation()
fib = @oldprocess fibonnaci(sim)
wait = @oldprocess wait_for_process(sim, fib)
run(sim)

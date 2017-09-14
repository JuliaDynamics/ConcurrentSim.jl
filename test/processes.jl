using SimJulia
using ResumableFunctions

@resumable function fibonnaci(sim::Simulation)
  a = 0
  b = 1
  while true
    println(a)
    @yield Timeout(sim, 1)
    a, b = b, a+b
  end
end

@resumable function test_process(sim::Simulation, ev::AbstractEvent)
  @yield ev
end

@resumable function test_process_exception(sim::Simulation, ev::AbstractEvent)
  try
    value = @yield ev
  catch exc
    println("$exc has been thrown")
  end
end

@resumable function test_interrupter(sim::Simulation, proc::Process)
  @yield Timeout(sim, 2)
  interrupt(proc)
end

@resumable function test_interrupted(sim::Simulation)
  try
    @yield Timeout(sim, 10)
  catch exc
    if isa(exc, SimJulia.InterruptException)
      println("$(active_process(sim)) interrupted")
    end
  end
  @yield Timeout(sim, 10)
  throw(TestException())
end

sim = Simulation()
@process fibonnaci(sim)
run(sim, 10)

sim = Simulation()
@process test_process(sim, succeed(Event(sim)))
run(sim)

sim = Simulation()
@process test_process_exception(sim, Timeout(sim, 1, value=TestException()))
try
  run(sim)
catch exc
  println("$exc has been thrown")
end

sim = Simulation()
@process test_process_exception(sim, Timeout(sim, value=TestException()))
run(sim)

sim = Simulation()
proc = @process test_interrupted(sim)
@process test_interrupter(sim, proc)
try
  run(sim)
catch exc
  println("$exc has been thrown")
end

using SimJulia

@resumable function fibonnaci(sim::Simulation)
  a = 0
  b = 1
  while true
    println(a)
    @yield timeout(sim, 1)
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
  @yield timeout(sim, 2)
  @yield interrupt(proc)
end

@resumable function test_interrupted(sim::Simulation)
  try
    @yield timeout(sim, 10)
  catch exc
    if isa(exc, SimJulia.InterruptException)
      println("$(active_process(sim)) interrupted")
    end
  end
  @yield timeout(sim, 10)
  throw(TestException())
end

sim = Simulation()
@process fibonnaci(sim)
println(sim)
run(sim, 10)

sim = Simulation()
@process test_process(sim, succeed(Event(sim)))
run(sim)

sim = Simulation()
@process test_process_exception(sim, timeout(sim, 1, value=TestException()))
try
  run(sim)
catch exc
  println("$exc has been thrown")
end

sim = Simulation()
@process test_process_exception(sim, timeout(sim, value=TestException()))
run(sim)

sim = Simulation()
proc = @process test_interrupted(sim)
@process test_interrupter(sim, proc)
try
  run(sim)
catch exc
  println("$exc has been thrown")
end

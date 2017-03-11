using SimJulia

@stateful function fibonnaci(sim::Simulation)
  a = 0
  b = 1
  while true
    println(a)
    @yield return Timeout(sim, 1)
    a, b = b, a+b
  end
end

@stateful function test_process(sim::Simulation, ev::AbstractEvent)
  @yield return ev
end

@stateful function test_process_exception(sim::Simulation, ev::AbstractEvent)
  try
    value = @yield return ev
  catch
    println("$value has been thrown")
  end
end

@stateful function test_interrupter(sim::Simulation, proc::Coroutine)
  @yield return Timeout(sim, 2)
  interrupt(proc)
end

@stateful function test_interrupted(sim::Simulation)
  try
    exc = @yield return Timeout(sim, 10)
  catch
    if isa(exc, SimJulia.InterruptException)
      println("$(active_process(sim)) interrupted")
    end
  end
  @yield return Timeout(sim, 10)
  throw(TestException())
end

sim = Simulation()
@Coroutine fibonnaci(sim)
run(sim, 10)

sim = Simulation()
@Coroutine test_process(sim, succeed(Event(sim)))
run(sim)

sim = Simulation()
@Coroutine test_process_exception(sim, Timeout(sim, 1, value=TestException()))
try
  run(sim)
catch exc
  println("$exc has been thrown")
end

sim = Simulation()
@Coroutine test_process_exception(sim, Timeout(sim, value=TestException()))
run(sim)

sim = Simulation()
proc = @Coroutine test_interrupted(sim)
@Coroutine test_interrupter(sim, proc)
try
  run(sim)
catch exc
  println("$exc has been thrown")
end

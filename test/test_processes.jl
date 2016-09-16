using SimJulia

type TestException <: Exception end

function fib(sim::Simulation)
  a = 0
  b = 1
  while true
    println("time: $(now(sim)); value: $b")
    try
      yield(sim, timeout(sim, 1))
    catch(exc)
      break
    end
    a, b = b, a+b
  end
end

function inter(sim::Simulation, p::Process)
  yield(sim, timeout(sim, 5))
  interrupt(sim, p)
  yield(sim, p)
  println("Fibonnaci has ended")
end

sim = Simulation()
p = Process(sim, fib)
Process(sim, inter, p)
run(sim)

function throwexc(sim::Simulation)
  throw(TestException())
end

function yield_p(sim::Simulation, p::Process)
  yield(sim, p)
end

sim = Simulation()
p = Process(sim, throwexc)
Process(sim, yield_p, p)
try
  run(sim)
catch(exc)
  println(exc)
end

function yield_processed(sim::Simulation, ev::Event)
  println(state(ev))
  println(yield(sim, ev))
end

sim = Simulation()
Process(sim, yield_processed, timeout(sim, value="OK"))
run(sim)

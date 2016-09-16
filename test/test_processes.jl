using SimJulia

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

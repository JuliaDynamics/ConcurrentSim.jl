using SimJulia

function fib(sim::Simulation)
  a = 0
  b = 1
  while true
    println("time: $(now(sim)); value: $b")
    yield(sim, schedule(sim, Event(), 1))
    a, b = b, a+b
  end
end

sim = Simulation()
Process(sim, fib)
run(sim, 6)

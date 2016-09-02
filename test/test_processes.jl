using SimJulia

function fib(sim::Simulation, proc::Process)
  a = 0
  b = 1
  while true
    println("time: $(now(sim)); value: $b")
    yield(proc, Event(sim, 1))
    a, b = b, a+b
  end
end

sim = Simulation()
Process(sim, fib)
run(sim, 6)

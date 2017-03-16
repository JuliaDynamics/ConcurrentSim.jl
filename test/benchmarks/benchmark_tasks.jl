using SimJulia, BenchmarkTools

function fibonnaci(sim::Simulation{SimJulia.SimulationTime})
  a = BigInt(0)
  b = BigInt(1)
  while true
    SimJulia.produce(Timeout(sim, 1))
    a, b = b, a+b
  end
end

function run_test()
  sim = Simulation()
  fib = @task fibonnaci(sim)
  for i in 1:10
    SimJulia.consume(fib)
  end
end

run_test()
BenchmarkTools.DEFAULT_PARAMETERS.samples = 100
println(mean(@benchmark run_test()))

using SimJulia, BenchmarkTools

@stateful function fibonnaci(sim::Simulation)
  a = 0.0
  b = 1.0
  while true
    @yield return nothing
    a, b = b, a+b
  end
end

function run_test()
  sim = Simulation()
  fib = fibonnaci(sim)
  for i in 1:10
    fib()
  end
end

run_test()
BenchmarkTools.DEFAULT_PARAMETERS.samples = 100
println(mean(@benchmark run_test()))

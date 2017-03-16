using SimJulia, BenchmarkTools

@stateful function fibonnaci{T<:TimeType}(sim::Simulation{T})
  a = BigInt(0)
  b = BigInt(1)
  while true
    @yield return Timeout(sim, 1)
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

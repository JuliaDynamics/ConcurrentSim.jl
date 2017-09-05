using ResumableFunctions, SimJulia, BenchmarkTools

@resumable function fibonnaci(sim::Simulation)
  a = 0.0
  b = 1.0
  while true
    @yield Timeout(sim, 1)
    a, b = b, a+b
  end
end

function run_test()
  sim = Simulation()
  @coroutine fibonnaci(sim)
  run(sim, 10)
end

run_test()
BenchmarkTools.DEFAULT_PARAMETERS.samples = 100
println(mean(@benchmark run_test()))
#@profile for i in 1:100; run_test(); end
#Profile.print(format=:flat)

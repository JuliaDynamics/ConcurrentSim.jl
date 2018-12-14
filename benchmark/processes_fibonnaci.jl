using ResumableFunctions, SimJulia, BenchmarkTools

@resumable function fibonnaci(sim::Simulation)
  a = 0.0
  b = 1.0
  while true
    @yield timeout(sim, 1)
    a, b = b, a+b
  end
end

function run_test()
  sim = Simulation()
  @process fibonnaci(sim)
  run(sim, 10)
end

run_test()
@btime run_test()

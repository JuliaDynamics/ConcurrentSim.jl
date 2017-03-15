using SimJulia, Distributions, BenchmarkTools

function exp_source(sim::Simulation, lambd::Float64, server::Resource, mu::Float64)
  while true
    dt = rand(Exponential(1/lambd))
    yield(Timeout(sim, dt))
    @Process customer2(sim, server, mu)
  end
end

function customer(sim::Simulation, server::Resource, mu::Float64)
  yield(Request(server))
  dt = rand(Exponential(1/mu))
  yield(Timeout(sim, dt))
  yield(Release(server))
end

function customer2(sim::Simulation, server::Resource, mu::Float64)
  Request(server) do req
    dt = rand(Exponential(1/mu))
    yield(Timeout(sim, dt))
  end
end

function test_mm1(n::Float64)
  sim = Simulation()
  server = Resource(sim, 1)
  @Process exp_source(sim, 1.0, server, 1.1)
  run(sim, n)
end

BenchmarkTools.DEFAULT_PARAMETERS.samples = 100
println(mean(@benchmark test_mm1(100.0)))

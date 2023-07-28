using ConcurrentSim, Distributions, BenchmarkTools

function exp_source(sim::Simulation, lambd::Float64, server::Resource, mu::Float64)
  while true
    dt = rand(Exponential(1/lambd))
    yield(timeout(sim, dt))
    @oldprocess customer(sim, server, mu)
  end
end

function customer(sim::Simulation, server::Resource, mu::Float64)
  yield(lock(server))
  dt = rand(Exponential(1/mu))
  yield(timeout(sim, dt))
  yield(release(server))
end

function customer2(sim::Simulation, server::Resource, mu::Float64)
  lock(server) do req
    yield(req)
    dt = rand(Exponential(1/mu))
    yield(timeout(sim, dt))
  end
end

function test_mm1(n::Float64)
  sim = Simulation()
  server = Resource(sim)
  @oldprocess exp_source(sim, 1.0, server, 1.1)
  run(sim, n)
end

test_mm1(100.0)
@btime test_mm1(100.0)

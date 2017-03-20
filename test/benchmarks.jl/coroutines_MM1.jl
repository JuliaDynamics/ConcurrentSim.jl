using SimJulia, Distributions, BenchmarkTools

@stateful function exp_source(sim::Simulation{SimJulia.SimulationTime}, lambd::Float64, server::Resource, mu::Float64)
  while true
    dt = rand(Exponential(1/lambd))
    @yield return Timeout(sim, dt)
    @coroutine customer2(sim, server, mu)
  end
end

@stateful function customer(sim::Simulation{SimJulia.SimulationTime}, server::Resource{Simulation{SimJulia.SimulationTime}}, mu::Float64)
  @yield return Request(server)
  dt = rand(Exponential(1/mu))
  @yield return Timeout(sim, dt)
  @yield return Release(server)
end

@stateful function customer2(sim::Simulation{SimJulia.SimulationTime}, server::Resource{Simulation{SimJulia.SimulationTime}}, mu::Float64)
  @request server req begin
    dt = rand(Exponential(1/mu))
    @yield return Timeout(sim, dt)
  end
end

function test_mm1(n::Float64)
  sim = Simulation()
  server = Resource(sim, 1)
  @coroutine exp_source(sim, 1.0, server, 1.1)
  run(sim, n)
end

BenchmarkTools.DEFAULT_PARAMETERS.samples = 100
println(mean(@benchmark test_mm1(100.0)))

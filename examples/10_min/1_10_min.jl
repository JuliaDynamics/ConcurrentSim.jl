using SimJulia

function clock(sim::Simulation, name::String, tick::Float64)
  while true
    println("$name, $(now(sim))")
    yield(Timeout(sim, tick))
  end
end

sim = Simulation()
Process(clock, sim, "fast", 0.5)
Process(clock, sim, "slow", 1.0)
run(sim, 2.0)

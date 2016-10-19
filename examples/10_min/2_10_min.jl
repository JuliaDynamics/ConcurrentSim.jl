using SimJulia

function car(sim::Simulation)
  while true
    println("Start parking at $(now(sim))")
    parking_duration = 5
    yield(Timeout(sim, parking_duration))
    println("Start driving at $(now(sim))")
    trip_duration = 2
    yield(Timeout(sim, trip_duration))
  end
end

sim = Simulation()
Process(car, sim)
run(sim, 15)

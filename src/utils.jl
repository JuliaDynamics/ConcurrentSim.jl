timeout(sim::Simulation, delay::Number=0; priority::Bool=false, value::Any=nothing) = schedule(sim, Event(), delay, priority=priority, value=value)
timeout(sim::Simulation, delay::Period; priority::Bool=false, value::Any=nothing) = schedule(sim, Event(), delay, priority=priority, value=value)

type Simulation
	stop::Bool
	time::Float64
	sort_priority::Int64
	event_list::EventList
	monitors::Set{Monitor}
	function Simulation(n::Uint64)
		simulation = new()
		simulation.stop = false
		simulation.time = typemin(Float64)
		simulation.sort_priority = 0
		simulation.event_list = EventList(n)
		simulation.monitors = Set{Monitor}()
		return simulation
	end
end

function run(simulation::Simulation, until::Float64)
	for (task, simulation.time) in simulation.event_list
		if simulation.time > until
			simulation.stop = true
		end
		consume(task)
		if simulation.stop
			break
		end
	end
end

function register(simulation::Simulation, monitor::Monitor)
	add!(simulation.monitors, monitor)
end

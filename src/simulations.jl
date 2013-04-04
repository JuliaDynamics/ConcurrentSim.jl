type Simulation
	stop::Bool
	time::Float64
	sort_priority::Int64
	event_list::EventList
	monitors::Set{Monitor}
	function Simulation(n::Uint)
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
	stop_monitors(simulation)
end

function register(simulation::Simulation, monitor::Monitor)
	add!(simulation.monitors, monitor)
	reset(monitor, 0.0)
end

function reset(simulation::Simulation)
	for monitor in simulation.monitors
		reset(monitor, simulation.time)
	end
end

function stop_monitors(simulation::Simulation)
	for monitor in simulation.monitors
		stop(monitor, simulation.time)
	end
end

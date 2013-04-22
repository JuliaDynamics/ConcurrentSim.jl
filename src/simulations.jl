type Simulation
	stop::Bool
	time::Float64
	sort_priority::Int
	event_list::EventList
	condition_list::Dict{Task,Function}
	monitors::Set{Monitor}
	function Simulation(n::Uint)
		simulation = new()
		simulation.stop = false
		simulation.time = typemin(Float64)
		simulation.sort_priority = 0
		simulation.event_list = EventList(n)
		simulation.condition_list = Dict{Task,Function}()
		simulation.monitors = Set{Monitor}()
		return simulation
	end
end

function run(simulation::Simulation, until::Float64)
	for (task, simulation.time) in simulation.event_list
		if simulation.time > until || simulation.stop
			break
		end
		consume(task)
		for (cond_task, condition) in simulation.condition_list
			if condition()
				delete!(simulation.condition_list, cond_task)
				consume(cond_task)
			end
		end
	end
	stop_monitors(simulation)
end

function add_condition(simulation::Simulation, task::Task, condition::Function)
	simulation.condition_list[task] = condition
end

function register(simulation::Simulation, monitor::Monitor)
	add!(simulation.monitors, monitor)
	reset(monitor, 0.0)
end

function stop_monitors(simulation::Simulation)
	for monitor in simulation.monitors
		stop(monitor, simulation.time)
	end
end

function stop(simulation::Simulation)
	simulation.stop = true
end

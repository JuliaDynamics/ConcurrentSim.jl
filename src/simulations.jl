type Simulation
	stop::Bool
	time::Float64
	sort_priority::Int
	event_list::Heap{Event}
	condition_list::Dict{Task,Function}
	monitors::Set{Monitor}
	continuous_list::Set{Continuous}
	dt_min::Float64
	dt_max::Float64
	function Simulation(n::Uint)
		simulation = new()
		simulation.stop = false
		simulation.time = typemin(Float64)
		simulation.sort_priority = 0
		simulation.event_list = Heap{Event}(n)
		simulation.condition_list = Dict{Task,Function}()
		simulation.monitors = Set{Monitor}()
		simulation.continuous_list = Set{Continuous}()
		simulation.dt_min = 1.0e-5
		simulation.dt_max = 1.0
		return simulation
	end
end

function run(simulation::Simulation, until::Float64)
	for (task, new_time) in simulation.event_list
		if new_time > until || simulation.stop
			break
		end
		simulation.time = new_time
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

function run_continuous(simulation::Simulation, until::Float64)
	dt_next = 0.0
	while true
		(task, next_event_time) = next_event(simulation.event_list)
		dt = 0.0
		for continuous in simulation.continuous_list
			save_state(continuous)
			calculate_derivatives(continuous)
		end
		while simulation.time < next_event_time
			last_time = simulation.time

		end

		if next_event_time > until || simulation.stop
			break
		end
		simulation.time = next_event_time
		remove_first(simulation.event_list)
		consume(task)
	end
	stop_monitors(simulation)
end

function add_condition(simulation::Simulation, task::Task, condition::Function)
	simulation.condition_list[task] = condition
end

function add_variables(simulation::Simulation, variables::Vector{Variable}, derivative::Function)
	add!(simulation.continuous_list, Continuous(variables, derivative))
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

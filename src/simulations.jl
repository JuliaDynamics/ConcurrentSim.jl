type Simulation
	stop::Bool
	time::Float64
	time_priority::Int
	state_priority::Int
	time_events::Heap{TimeEvent}
	state_events::Vector{StateEvent}
	monitors::Set{Monitor}
	variables::Set{Variable}
	derivatives::Set{Continuous}
	dt_min::Float64
	dt_max::Float64
	max_abs_error::Float64
	max_rel_error::Float64
	function Simulation(n::Uint)
		simulation = new()
		simulation.stop = false
		simulation.time = 0.0
		simulation.time_priority = 0
		simulation.state_priority = 0
		simulation.time_events = Heap{TimeEvent}(n)
		simulation.state_events = StateEvent[]
		simulation.monitors = Set{Monitor}()
		simulation.variables = Set{Variable}()
		simulation.derivatives = Set{Continuous}()
		simulation.dt_min = 1.0e-5
		simulation.dt_max = 1.0
		simulation.max_abs_error = 1.0e-5
		simulation.max_rel_error = 1.0e-5
		return simulation
	end
end

function run(simulation::Simulation, until::Float64)
	dt_next = simulation.dt_max
	while true
		next_event_time = top(simulation.time_events)
		if next_event_time > until && isempty(simulation.state_events) || simulation.stop
			break
		end
		compute_derivatives(simulation.time, simulation.derivatives)
		if check(simulation.state_events)
			next_event_time = simulation.time
		end
		while simulation.time < next_event_time 
			next_time = next_event_time
			save_state(simulation.variables)
			last_time = simulation.time
			dt_now = next_event_time - last_time
			if ! isempty(simulation.derivatives)
				dt_now = min(dt_now, dt_next)
				(dt_now, dt_next) = integrate(simulation.variables, simulation.derivatives, last_time, dt_now, dt_next, simulation.dt_min, simulation.dt_max, simulation.max_abs_error, simulation.max_rel_error)
				next_time = last_time + dt_now
			end
			dt_full = dt_now
			simulation.time = next_time
			if check(simulation.state_events)
				prepare_interpolation(simulation.variables, dt_full)
				dt_lower = 0.0
				dt = 0.0
				while dt_now - dt_lower > simulation.dt_min
					dt = max(0.5 * (dt_lower + dt_now), simulation.dt_min)
					simulation.time = last_time + dt
					interpolate(simulation.variables, dt, dt_full)
					compute_derivatives(simulation.time, simulation.derivatives)
					if check(simulation.state_events)
						dt_now = dt
					else
						dt_lower = dt
					end
				end
				if dt == dt_lower
					simulation.time = last_time + dt_now
					interpolate(simulation.variables, dt_now, dt_full)
					compute_derivatives(simulation.time, simulation.derivatives)
				end
				next_event_time = simulation.time
			end
		end
		if check(simulation.state_events)
			task = pop!(simulation.state_events)
			consume(task)
		else
			task = pop!(simulation.time_events)
			consume(task)
		end
	end
	stop_monitors(simulation)
end

function post(simulation::Simulation, task::Task, at::Float64, priority::Bool)
	simulation.time_priority += 1
	if priority
		return push!(simulation.time_events, task, at, -simulation.time_priority)
	else
		return push!(simulation.time_events, task, at, simulation.time_priority)
	end
end

function post(simulation::Simulation, task::Task, condition::Function, priority::Bool)
	simulation.state_priority += 1
	if priority
		return push!(simulation.state_events, task, condition, -simulation.time_priority)
	else
		return push!(simulation.state_events, task, condition, simulation.time_priority)
	end
end

function start(simulation::Simulation, variables::Vector{Variable}, derivative::Function)
	for variable in variables
		add!(simulation.variables, variable)
	end
	add!(simulation.derivatives, Continuous(variables, derivative))
end

function stop(simulation::Simulation, variables::Vector{Variable}, derivative::Function)
	for variable in variables
		delete!(simulation.variables, variable)
	end
	for continuous in simulation.derivatives
		if continuous.derivative == derivative
			delete!(simulation.derivatives, continuous)
			break
		end
	end
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

type Process
	name::ASCIIString
	simulation::Simulation
	task::Task
	next_event::Event
	interrupt_left::Float64
	interrupt_cause::Process
	function Process(simulation::Simulation, name::ASCIIString)
		process = new()
		process.simulation = simulation
		process.name = name
		process.interrupt_left = -1.0
		return process
	end
end

function show(io::IO, process::Process)
	print(io, process.name)
end

function post(simulation::Simulation, process::Process, at::Float64, priority::Bool)
	simulation.sort_priority += 1
	if priority
		process.next_event = push!(simulation.event_list, process.task, at, -simulation.sort_priority)
	else
		process.next_event = push!(simulation.event_list, process.task, at, simulation.sort_priority)
	end
end

function cancel(process::Process)
	process.next_event.canceled = true
end

function now(process::Process)
	return copy(process.simulation.time)
end

function terminated(process::Process)
	return istaskdone(process.task)
end

function interrupted(process::Process)
	return ! terminated(process) && process.interrupt_left >= 0.0
end

function active(process::Process)
	return process.interrupt_left < 0.0 && process.next_event.time >= 0.0
end

function passive(process::Process)
	return ! terminated(process) && process.next_event.time < 0.0
end

function activate(process::Process, at::Float64, run::Function, args...)
	if length(args) == 0
		process.task = Task(()->run(process))
	elseif length(args) == 1
		process.task = Task(()->run(process, args[1]))
	elseif length(args) == 2
		process.task = Task(()->run(process, args[1], args[2]))
	elseif length(args) == 3
		process.task = Task(()->run(process, args[1], args[2], args[3]))
	elseif length(args) == 4
		process.task = Task(()->run(process, args[1], args[2], args[3], args[4]))
	elseif length(args) == 5
		process.task = Task(()->run(process, args[1], args[2], args[3], args[4], args[5]))
	else
		throw("Too many arguments!")
	end
	post(process.simulation, process, at, false)
end

function reactivate(process::Process, delay::Float64)
	process.next_event.canceled = true
	post(process.simulation, process, now(process)+delay, false)
end

function interrupt(victim::Process, cause::Process)
	if active(victim)
		victim.interrupt_left = victim.next_event.time - now(victim)
		victim.interrupt_cause = cause
		reactivate(victim, 0.0)
	end
end

function interrupt_left(process::Process)
	return copy(process.interrupt_left)
end

function interrupt_cause(process::Process)
	return process.interrupt_cause
end

function interrupt_reset(process::Process)
	process.interrupt_left = -1.0
end

function sleep(process::Process)
	process.next_event = Event()
	produce(true)
end

function hold(process::Process, delay::Float64)
	post(process.simulation, process, now(process)+delay, false)
	produce(true)
end

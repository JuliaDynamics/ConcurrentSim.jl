type Process
	name::ASCIIString
	simulation::Simulation
	task::Task
	next_event::TimeEvent
	interrupted::Bool
	interrupt_left::Float64
	interrupt_cause::Process
	function Process(simulation::Simulation, name::ASCIIString)
		process = new()
		process.simulation = simulation
		process.name = name
		process.next_event = TimeEvent()
		process.interrupted = false
		process.interrupt_left = 0.0
		return process
	end
end

function show(io::IO, process::Process)
	print(io, process.name)
end

function simulation(process::Process)
	return process.simulation
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
	return ! terminated(process) && process.interrupted
end

function active(process::Process)
	return ! process.interrupted && ! process.next_event.canceled
end

function passive(process::Process)
	return ! terminated(process) && process.next_event.canceled
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
	elseif length(args) == 6
		process.task = Task(()->run(process, args[1], args[2], args[3], args[4], args[5], args[6]))
	else
		throw("Too many arguments!")
	end
	process.next_event = post(process.simulation, process.task, at, false)
end

function reactivate(process::Process, delay::Float64)
	if passive(process)
		process.next_event.canceled = true
		process.next_event = post(process.simulation, process.task, now(process)+delay, false)
	end
end

function interrupt(victim::Process, cause::Process)
	if active(victim)
		victim.next_event.canceled = true
		victim.interrupted = true
		victim.interrupt_left = victim.next_event.time - now(victim)
		victim.interrupt_cause = cause
		victim.next_event = post(victim.simulation, victim.task, now(victim), true)
	end
end

function interrupt_left(process::Process)
	return copy(process.interrupt_left)
end

function interrupt_cause(process::Process)
	return process.interrupt_cause
end

function interrupt_reset(process::Process)
	process.interrupted = false
end

function sleep(process::Process)
	process.next_event = TimeEvent()
	produce(true)
end

function hold(process::Process, delay::Float64)
	process.next_event = post(process.simulation, process.task, now(process)+delay, false)
	produce(true)
end

function waituntil(process::Process, condition::Function, priority::Bool=false)
	process.next_event = TimeEvent()
	post(process.simulation, process.task, condition, priority)
	produce(true)
end

function reset_monitors(process::Process)
	simulation = simulation(process)
	for monitor in simulation.monitor
		reset(monitor, now(process))
	end
end

function start_collection(simulation::Simulation, time::Float64)
	process = Process(simulation, "Start collection")
	activate(process, time, reset_monitors)
end

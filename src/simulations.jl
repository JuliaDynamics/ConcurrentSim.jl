type Simulation
	stop::Bool
	time::Float64
	sort_priority::Int64
	event_list::EventList
	function Simulation(n::Uint64)
		simulation = new()
		simulation.stop = false
		simulation.time = typemin(Float64)
		simulation.sort_priority = 0
		simulation.event_list = EventList(n)
		return simulation
	end
end

type Process
	name::ASCIIString
	simulation::Simulation
	task::Task
	next_event::Event
	function Process(simulation::Simulation, name::ASCIIString)
		process = new()
		process.simulation = simulation
		process.name = name
		return process
	end
end

function show(io::IO, process::Process)
	print(io, process.name)
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

function post(simulation::Simulation, process::Process, at::Float64, priority::Bool)
	simulation.sort_priority += 1
	if priority
		process.next_event = push!(simulation.event_list, process.task, at, -simulation.sort_priority)
	else
		process.next_event = push!(simulation.event_list, process.task, at, simulation.sort_priority)
	end
end

function now(process::Process)
	return copy(process.simulation.time)
end

function done(process::Process)
	return istaskdone(process.task)
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

function reactivate(process::Process, at::Float64)
	process.next_event.canceled = true
	post(process.simulation, process, at, false)
end

function sleep(process::Process)
	process.next_event = Event()
end

function hold(process::Process, delay::Float64)
	post(process.simulation, process, now(process)+delay, false)
end

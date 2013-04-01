type Signal
	name::ASCIIString
	wait_list::Set{Process}
	queue_list::Vector{Process}
	function Signal(name::ASCIIString)
		signal = new()
		signal.name = name
		signal.wait_list = Set{Process}()
		signal.queue_list = Process[]
		return signal
	end
end

function show(io::IO, signal::Signal)
	print(io, signal.name)
end

function wait(process::Process, signals::Set{Signal})
	for signal in signals
		add!(signal.wait_list, process)
	end
	process.next_event = Event()
	produce(true)
	for signal in signals
		delete!(signal.wait_list, process)
	end
end

function wait(process::Process, signal::Signal)
	signals = Set{Signal}()
	add!(signals, signal)
	wait(process, signals)
end

function queue(process::Process, signals::Set{Signal})
	for signal in signals
		push!(signal.queue_list, process)
	end
	process.next_event = Event()
	produce(true)
	for signal in signals
		delete!(signal.queue_list, findin(signal.queue_list, [process])[1])
	end
end

function queue(process::Process, signal::Signal)
	signals = Set{Signal}()
	add!(signals, signal)
	queue(process, signals)
end

function fire(signal::Signal)
	for process in signal.wait_list
		post(process.simulation, process, now(process), true)
	end
	if ! isempty(signal.queue_list)
		process = signal.queue_list[1]
		post(process.simulation, process, now(process), true)
	end
end
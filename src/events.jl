type Event
	task::Task
	time::Float64
	priority::Int64
	canceled::Bool
	function Event()
		event = new()
		event.time = -1.0
		event.canceled = true
		return event
	end
end

function Event(task::Task, time::Float64, priority::Int64)
	event = Event()
	event.task = task
	event.time = time
	event.priority = priority
	event.canceled = false
	return event
end

function show(io::IO, event::Event)
	print(io, "Event: $(event.task), $(event.time), $(event.priority), $(event.canceled)")
end

function isless(event1::Event, event2::Event)
	return event1.time < event2.time || (event1.time == event2.time && event1.priority < event2.priority)
end

type EventList
	count::Uint64
	heap::Vector{Event}
	function EventList(n::Uint)
		new(uint(0), Array(Event, n))
	end
end

function show(io::IO, event_list::EventList)
	print(io, "EventList: $(event_list.count)")
end

function percolate_up(event_list::EventList)
	position = event_list.count
	parent = convert(Uint, ifloor(position/2))
	while position > 1 && event_list.heap[position] < event_list.heap[parent]
		event_list.heap[position], event_list.heap[parent] = event_list.heap[parent], event_list.heap[position]
		position = parent
		parent = convert(Uint, ifloor(position/2))
	end
end

function percolate_down(event_list::EventList)
	position = 1
	left = 2*position
	while left <= event_list.count
		smallest = event_list.heap[left] < event_list.heap[position] ? left : position
		if left < event_list.count
			smallest = event_list.heap[left+1] < event_list.heap[smallest] ? left+1 : smallest
		end
		if smallest == position
			return
		end
		event_list.heap[smallest], event_list.heap[position] = event_list.heap[position], event_list.heap[smallest]
		position = smallest
		left = 2*position
	end
end

function push!(event_list::EventList, task::Task, time::Float64, priority::Int64)
	if event_list.count == length(event_list.heap)
		throw("Heap overflow!")
	end
	event_list.count += 1
	event = Event(task, time, priority)
	event_list.heap[event_list.count] = event
	percolate_up(event_list)
	return event
end

function pop!(event_list::EventList)
	result = Event()
	while event_list.count > 0
		result = event_list.heap[1]
		event_list.heap[1] = event_list.heap[event_list.count]
		event_list.heap[event_list.count] = Event()
		event_list.count -= 1
		percolate_down(event_list)
		if ! result.canceled
			return result.task, result.time
		end
	end
	return Task(()->print("")), result.time
end

function start(event_list::EventList)
	return event_list.count
end

function done(event_list::EventList, state::Uint64)
	return event_list.count == 0
end

function next(event_list::EventList, state::Uint64)
	return pop!(event_list), event_list.count
end

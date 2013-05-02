type Event
	task::Task
	time::Float64
	priority::Int
	canceled::Bool
	function Event()
		event = new()
		event.time = -1.0
		event.canceled = true
		return event
	end
end

function Event(task::Task, time::Float64, priority::Int)
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

type Heap{E}
	count::Uint
	array::Vector{E}
	function Heap(n::Uint)
		new(uint(0), Array(E, n))
	end
end

function percolate_up{E}(heap::Heap{E})
	position = heap.count
	parent = convert(Uint, ifloor(position/2))
	while position > 1 && heap.array[position] < heap.array[parent]
		heap.array[position], heap.array[parent] = heap.array[parent], heap.array[position]
		position = parent
		parent = convert(Uint, ifloor(position/2))
	end
end

function percolate_down{E}(heap::Heap{E})
	position = 1
	left = 2*position
	while left <= heap.count
		smallest = heap.array[left] < heap.array[position] ? left : position
		if left < heap.count
			smallest = heap.array[left+1] < heap.array[smallest] ? left+1 : smallest
		end
		if smallest == position
			return
		end
		heap.array[smallest], heap.array[position] = heap.array[position], heap.array[smallest]
		position = smallest
		left = 2*position
	end
end

function push!(heap::Heap{Event}, task::Task, time::Float64, priority::Int)
	if heap.count == length(heap.array)
		throw("Heap overflow!")
	end
	heap.count += 1
	event = Event(task, time, priority)
	heap.array[heap.count] = event
	percolate_up(heap)
	return event
end

function shift!(heap::Heap{Event})
	result = Event()
	while heap.count > 0
		result = heap.array[1]
		heap.array[1] = heap.array[heap.count]
		heap.array[heap.count] = Event()
		heap.count -= 1
		percolate_down(heap)
		if ! result.canceled
			return result.task, result.time
		end
	end
	return Task(()->()), result.time
end

function next_event(heap::Heap{Event})
	result = Event()
	while heap.count > 0
		result = heap.array[1]
		if ! result.canceled
			return result.task, result.time
		end
		heap.array[1] = heap.array[heap.count]
		heap.array[heap.count] = Event()
		heap.count -= 1
		percolate_down(heap)
	end
	return Task(()->()), Inf
end

function remove_first(heap::Heap{Event})
	if heap.count > 0
		heap.array[1] = heap.array[heap.count]
		heap.array[heap.count] = Event()
		heap.count -= 1
		percolate_down(heap)
	end
end	

function start(heap::Heap{Event})
	return heap.count
end

function done(heap::Heap{Event}, state::Uint)
	return heap.count == 0
end

function next(heap::Heap{Event}, state::Uint)
	return shift!(heap), heap.count
end

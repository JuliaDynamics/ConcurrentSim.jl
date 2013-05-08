type TimeEvent
	task::Task
	time::Float64
	priority::Int
	canceled::Bool
	function TimeEvent()
		event = new()
		event.task = Task(()->())
		event.time = Inf
		event.canceled = true
		return event
	end
end

function TimeEvent(task::Task, time::Float64, priority::Int)
	event = TimeEvent()
	event.task = task
	event.time = time
	event.priority = priority
	event.canceled = false
	return event
end

function show(io::IO, event::TimeEvent)
	print(io, "TimeEvent: $(event.task), $(event.time), $(event.priority), $(event.canceled)")
end

function isless(event1::TimeEvent, event2::TimeEvent)
	return event1.time < event2.time || (event1.time == event2.time && event1.priority < event2.priority)
end


function push!(heap::Heap{TimeEvent}, task::Task, time::Float64, priority::Int)
	if heap.count == length(heap.array)
		throw("Heap overflow!")
	end
	heap.count += 1
	event = TimeEvent(task, time, priority)
	heap.array[heap.count] = event
	percolate_up(heap)
	return event
end

function top(heap::Heap{TimeEvent})
	while heap.count > 0
		result = heap.array[1]
		if ! result.canceled
			return result.time
		end
		heap.array[1] = heap.array[heap.count]
		heap.array[heap.count] = TimeEvent()
		heap.count -= 1
		percolate_down(heap)
	end
	return Inf
end

function pop!(heap::Heap{TimeEvent})
	result = heap.array[1]
	if heap.count > 0
		heap.array[1] = heap.array[heap.count]
		heap.array[heap.count] = TimeEvent()
		heap.count -= 1
		percolate_down(heap)
	end
	return result.task
end	

type StateEvent
	task::Task
	condition::Function
	priority::Int
end

function isless(event1::StateEvent, event2::StateEvent)
	return event1.priority < event2.priority
end

function check(list::Vector{StateEvent})
	for event in list
		if event.condition()
			return true
		end
	end
	return false
end

function push!(list::Vector{StateEvent}, task::Task, condition::Function, priority::Int)
	event = StateEvent(task, condition, priority)
	push!(list, event)
	return event
end

function pop!(list::Vector{StateEvent})
	priority = typemin(Int)
	index = 0
	for i in 1:length(list)
		if list[i].priority > priority && list[i].condition()
			priority = list[i].priority
			index = i
		end
	end
	event = delete!(list, index)
	return event.task
end
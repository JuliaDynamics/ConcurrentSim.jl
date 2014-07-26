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

type Element{V,P<:Real}
	value::V
	priority::P
	function Element()
		element = new()
		element.priority = zero(P)
		return element
	end
	function Element(value::V, priority::P)
		new(value, priority)
	end
end

function show(io::IO, element::Element)
	print(io, "Element: $(element.value), $(element.priority)")
end

function isless(element1::Element, element2::Element)
	return element1.priority < element2.priority
end

type PriorityQueue{V,P<:Real}
	elements::Vector{Element{V,P}}
	function PriorityQueue()
		new(Element{V,P}[])
	end
end

function show(io::IO, priority_queue::PriorityQueue)
	print(io, "PriorityQueue: $(length(priority_queue.elements))")
end

function length(priority_queue::PriorityQueue)
	return length(priority_queue.elements)
end

function unshift!{V,P<:Real}(priority_queue::PriorityQueue{V,P}, value::V, priority::P)
	element = Element{V,P}(value, priority)
	unshift!(priority_queue.elements, element)
	return element
end

function push!{V,P<:Real}(priority_queue::PriorityQueue{V,P}, value::V, priority::P)
	element = Element{V,P}(value, priority)
	push!(priority_queue.elements, element)
	return element
end

function shift!(priority_queue::PriorityQueue)
	if length(priority_queue.elements) == 0
		throw("PriorityQueue underflow!")
	end
	result, idx = findmax(priority_queue.elements)
	splice!(priority_queue.elements, idx)
	return result.value, result.priority
end

function delete!{V,P<:Real}(priority_queue::PriorityQueue{V,P}, value::V)
	for i = 1:length(priority_queue.elements)
		if priority_queue.elements[i].value == value
			splice!(priority_queue.elements, i)
			break
		end
	end
end

function start(priority_queue::PriorityQueue)
	return priority_queue.count
end

function done(priority_queue::PriorityQueue, state::Uint)
	return priority_queue.count == 0
end

function next(priority_queue::PriorityQueue, state::Uint)
	return pop!(priority_queue), priority_queue.count
end

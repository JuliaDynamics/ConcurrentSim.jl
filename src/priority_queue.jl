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

function isless{V,P<:Real}(element1::Element{V,P}, element2::Element{V,P})
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

function length{V,P<:Real}(priority_queue::PriorityQueue{V,P})
	return length(priority_queue.elements)
end

function push!{V,P<:Real}(priority_queue::PriorityQueue{V,P}, value::V, priority::P)
	element = Element{V,P}(value, priority)
	push!(priority_queue.elements, element)
	return element
end

function pop!{V,P<:Real}(priority_queue::PriorityQueue{V,P})
	if length(priority_queue.elements) == 0
		throw("Heap underflow!")
	end
	result, idx = findmax(priority_queue.elements)
	delete!(priority_queue.elements, idx)
	return result.value, result.priority
end

function delete!{V,P<:Real}(priority_queue::PriorityQueue{V,P}, value::V)
	for i = 1:length(priority_queue.elements)
		if priority_queue.elements[i].value == value
			delete!(priority_queue.elements, i)
			break
		end
	end
end

function start{V,P<:Real}(priority_queue::PriorityQueue{V,P})
	return priority_queue.count
end

function done{V,P<:Real}(priority_queue::PriorityQueue{V,P}, state::Uint64)
	return priority_queue.count == 0
end

function next{V,P<:Real}(priority_queue::PriorityQueue{V,P}, state::Uint64)
	return pop!(priority_queue), priority_queue.count
end

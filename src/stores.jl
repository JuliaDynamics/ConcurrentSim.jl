type Store{T}
	name::ASCIIString
	capacity::Int64
	occupied::Int64
	buffer::Vector{T}
	put_set::Dict{Process,Vector{T}}
	get_set::Dict{Process,Function}
	getted_set::Dict{Process,Vector{T}}
	put_queue::PriorityQueue{Process,Int64}
	get_queue::PriorityQueue{Process,Int64}
	monitored::Bool
	put_monitor::Monitor{Int64}
	get_monitor::Monitor{Int64}
	buffer_monitor::Monitor{Int64}
	function Store(simulation::Simulation, name::ASCIIString, capacity::Int64, initial_buffered::Vector{T}, monitored::Bool)
		store = new()
		store.name = name
		store.capacity = capacity
		store.occupied = length(initial_buffered)
		store.buffer = T[]
		append!(store.buffer, initial_buffered)
		store.put_set = Dict{Process,Vector{T}}()
		store.get_set = Dict{Process,Function}()
		store.getted_set = Dict{Process,Vector{T}}()
		store.put_queue = PriorityQueue{Process,Int64}()
		store.get_queue = PriorityQueue{Process,Int64}()
		store.monitored = monitored
		if monitored
			store.put_monitor = Monitor{Int64}("Put monitor of $name")
			register(simulation, store.put_monitor)
			store.get_monitor = Monitor{Int64}("Get monitor of $name")
			register(simulation, store.get_monitor)
			store.buffer_monitor = Monitor("Buffer monitor of $name", length(initial_buffered))
			register(simulation, store.buffer_monitor)
		end
		return store
	end
end

function buffer(store::Store)
	return copy(store.buffer)
end

function got(process::Process, store::Store)
	buffer = store.getted_set[process]
	delete!(store.getted_set, process)
	return buffer
end

function acquired(process::Process, store::Store)
	result = true
	if has(store.put_set, process)
		delete!(store.put_queue, process)
		if store.monitored
			observe(store.put_monitor, now(process), length(store.put_queue))
		end
		delete!(store.put_get, process)
		result = false
	elseif constains(store.get_set, process)
		delete!(store.get_queue, process)
		if store.monitored
			observe(store.get_monitor, now(process), length(store.get_queue))
		end
		delete!(store.get_set, process)
		result = false
	end
	return result
end

function put{T}(process::Process, store::Store, buffer::Vector{T}, priority::Int64, waittime::Float64, renege::Bool)
	if store.capacity - store.occupied < length(buffer) || length(store.put_queue) > 0
		store.put_set[process] = buffer
		push!(store.put_queue, process, priority)
		if store.monitored
			observe(store.put_monitor, now(process), length(store.put_queue))
		end
		if renege
			post(process.simulation, process, now(process)+waittime, true)
		end
	else
		append!(store.buffer, buffer)
		store.occupied += length(buffer)
		if store.monitored
			observe(store.buffer_monitor, now(process), store.occupied)
		end
		post(process.simulation, process, now(process), true)
		while length(store.get_queue) > 0
			new_process, new_priority = shift!(store.get_queue)
			filter = store.get_set[new_process]
			success, new_buffer = filter(copy(store.buffer))
			if (success)
				for element in new_buffer
					delete!(store.buffer, findin(store.buffer, [element])[1])
				end
				store.occupied -= length(new_buffer)
				if store.monitored
					observe(store.buffer_monitor, now(new_process), store.occupied)
					observe(store.get_monitor, now(new_process), length(store.get_queue))
				end
				store.getted_set[new_process] = new_buffer
				delete!(store.get_set, new_process)
				post(new_process.simulation, new_process, now(new_process), true)
			else
				unshift!(store.get_queue, new_process, new_priority)
				break
			end
		end
	end
	produce(true)
end

function put{T}(process::Process, store::Store, buffer::Vector{T}, priority::Int64, waittime::Float64)
	put(process, store, buffer, priority, waittime, true)
end

function put{T}(process::Process, store::Store, buffer::Vector{T}, priority::Int64)
	put(process, store, buffer, priority, Inf, false)
end

function put{T}(process::Process, store::Store, buffer::Vector{T}, waittime::Float64)
	put(process, store, buffer, 0, waittime, true)
end

function put{T}(process::Process, store::Store, buffer::Vector{T})
	put(process, store, buffer, 0, Inf, false)
end

function get(process::Process, store::Store, filter::Function, priority::Int64, waittime::Float64, renege::Bool)
	success, buffer = filter(copy(store.buffer))
	if ! success || length(store.get_queue) > 0
		store.get_set[process] =  filter
		push!(store.get_queue, process, priority)
		if store.monitored
			observe(store.get_monitor, now(process), length(store.get_queue))
		end
		if renege
			post(process.simulation, process, now(process)+waittime, true)
		end
	else
		for element in buffer
			delete!(store.buffer, findin(store.buffer, [element])[1])
		end
		store.occupied -= length(buffer)
		if store.monitored
			observe(store.buffer_monitor, now(process), store.occupied)
		end
		store.getted_set[process] = buffer
		post(process.simulation, process, now(process), true)
		while length(store.put_queue) > 0
			new_process, new_priority = shift!(store.put_queue)
			new_buffer = store.put_set[new_process]
			if store.capacity - store.occupied >= length(new_buffer)
				append!(store.buffer, new_buffer)
				store.occupied += length(new_buffer)
				if store.monitored
					observe(store.buffer_monitor, now(new_process), store.occupied)
					observe(store.put_monitor, now(new_process), length(store.put_queue))
				end
				delete!(store.put_set, new_process)
				post(new_process.simulation, new_process, now(new_process), true)
			else
				unshift!(store.put_queue, new_process, new_priority)
				break
			end
		end
	end
	produce(true)
end

function get(process::Process, store::Store, filter::Function, priority::Int64, waittime::Float64)
	get(process, store, filter, priority, waittime, true)
end

function get(process::Process, store::Store, filter::Function, priority::Int64)
	get(process, store, filter, priority, Inf, false)
end

function get(process::Process, store::Store, filter::Function, waittime::Float64)
	get(process, store, filter, 0, waittime, true)
end

function get(process::Process, store::Store, filter::Function)
	get(process, store, filter, 0, Inf, false)
end

function filter_number{T}(buffer::Vector{T}, number::Uint64)
	success = false
	selection = T[]
	if length(buffer) > number
		success = true
		append!(selection, buffer[1:number])
	end
	return success, selection
end

function get(process::Process, store::Store, number::Uint64, priority::Int64, waittime::Float64)
	get(process, store, (buffer::Vector{T})->filter_number(buffer, number), priority, waittime, true)
end

function get(process::Process, store::Store, number::Uint64, priority::Int64)
	get(process, store, (buffer::Vector{T})->filter_number(buffer, number), priority, Inf, false)
end

function get(process::Process, store::Store, number::Uint64, waittime::Float64)
	get(process, store, (buffer::Vector{T})->filter_number(buffer, number), 0, waittime, true)
end

function get{T}(process::Process, store::Store{T}, number::Uint64)
	get(process, store, (buffer::Vector{T})->filter_number(buffer, number), 0, Inf, false)
end

function put_monitor(store::Store)
	return store.put_monitor
end

function get_monitor(store::Store)
	return store.get_monitor
end

function buffer_monitor(store::Store)
	return store.buffer_monitor
end
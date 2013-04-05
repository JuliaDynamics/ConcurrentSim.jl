type Store{T}
	name::ASCIIString
	capacity::Uint64
	elements::Vector{T}
	monitored::Bool
	put_monitor::Monitor{Int64}
	get_monitor::Monitor{Int64}
	buffer_monitor::Monitor{Int64}
	function Store(simulation::Simulation, name::ASCIIString, capacity::Uint64, initial_buffered::Vector{T}, monitored::Bool)
		store = new()
		store.name = name
		store.capacity = capacity
		store.elements = T[]
		append!(store.elements, initial_buffered)
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

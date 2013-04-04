type Resource
	name::ASCIIString
	capacity::Uint64
	uncommitted::Uint64
	wait_queue::PriorityQueue{Process,Int64}
	active_set::Set{Process}
	monitored::Bool
	wait_monitor::Monitor{Int64}
	activity_monitor::Monitor{Int64}
	priority::Int64
	function Resource(simulation::Simulation, name::ASCIIString, capacity::Uint, monitored::Bool)
		resource = new()
		resource.name = name
		resource.capacity = capacity
		resource.uncommitted = capacity
		resource.wait_queue = PriorityQueue{Process,Int64}()
		resource.active_set = Set{Process}()
		resource.monitored = monitored
		if monitored
			resource.wait_monitor = Monitor{Int64}("Wait monitor of $name")
			register(simulation, resource.wait_monitor)
			resource.activity_monitor = Monitor{Int64}("Activity monitor of $name")
			register(simulation, resource.activity_monitor)
		end
		resource.priority = 0
		return resource
	end
end

function occupied(resource::Resource)
	return capacity - uncommitted
end

function acquired(process::Process, resource::Resource)
	result = true
	if ! contains(resource.active_set, process)
		delete!(resource.wait_queue, process)
		if resource.monitored
			observe(resource.wait_monitor, now(process), length(resource.wait_queue))
		end
		result = false
	end
	return result
end

function request(process::Process, resource::Resource, priority::Int64, waittime::Float64)
	if resource.uncommitted == 0
		element = push!(resource.wait_queue, process, priority)
		if resource.monitored
			observe(resource.wait_monitor, now(process), length(resource.wait_queue))
		end
		post(process.simulation, process, now(process)+waittime, true)
	else
		resource.uncommitted -= 1
		add!(resource.active_set, process)
		if resource.monitored
			observe(resource.activity_monitor, now(process), length(resource.active_set))
		end
		post(process.simulation, process, now(process), true)
	end
	produce(true)
end

function request(process::Process, resource::Resource, priority::Int64)
	request(process, resource, priority, Inf)
end

function request(process::Process, resource::Resource, waittime::Float64)
	resource.priority -= 1
	request(process, resource, resource.priority, waittime)
end

function request(process::Process, resource::Resource)
	resource.priority -= 1
	request(process, resource, resource.priority, Inf)
end

function release(process::Process, resource::Resource)
	resource.uncommitted += 1
	delete!(resource.active_set, process)
	if resource.monitored
		observe(resource.activity_monitor, now(process), length(resource.active_set))
	end
	if length(resource.wait_queue) > 0
		new_process, priority = pop!(resource.wait_queue)
		resource.uncommitted -= 1
		add!(resource.active_set, new_process)
		if resource.monitored
			observe(resource.wait_monitor, now(process), length(resource.wait_queue))
			observe(resource.activity_monitor, now(process), length(resource.active_set))
		end
		post(new_process.simulation, new_process, now(new_process), true)
	end
	post(process.simulation, process, now(process), true)
	produce(true)
end

function wait_monitor(resource::Resource)
	return resource.wait_monitor
end

function activity_monitor(resource::Resource)
	return resource.activity_monitor
end

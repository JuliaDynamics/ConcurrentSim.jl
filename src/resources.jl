type Resource
	simulation::Simulation
	name::ASCIIString
	capacity::Uint64
	uncommitted::Uint64
	wait_queue::Vector{Process}
	active_set::Set{Process}
	function Resource(simulation::Simulation, name::ASCIIString, capacity::Uint64)
		resource = new()
		resource.simulation = simulation
		resource.name = name
		resource.capacity = capacity
		resource.uncommitted = capacity
		resource.wait_queue = Process[]
		resource.active_set = Set{Process}()
		return resource
	end
end

function request(process::Process, resource::Resource)
	if resource.uncommitted == 0
		push!(resource.wait_queue, process)
	else
		resource.uncommitted -= 1
		add!(resource.active_set, process)
		post(process.simulation, process, now(process), true)
	end
end

function release(process::Process, resource::Resource)
	resource.uncommitted += 1
	delete!(resource.active_set, process)
	post(process.simulation, process, now(process), true)
	if length(resource.wait_queue) > 0
		new_process = shift!(resource.wait_queue)
		resource.uncommitted -= 1
		add!(resource.active_set, new_process)
		post(new_process.simulation, new_process, now(new_process), true)
	end
end

type Resource
	name::ASCIIString
	capacity::Uint64
	uncommitted::Uint64
	wait_queue::PriorityQueue{Process,Int64}
	active_set::Dict{Process, Int64}
	preempt_set::Dict{Process, Float64}
	monitored::Bool
	wait_monitor::Monitor{Int64}
	activity_monitor::Monitor{Int64}
	function Resource(simulation::Simulation, name::ASCIIString, capacity::Uint, monitored::Bool)
		resource = new()
		resource.name = name
		resource.capacity = capacity
		resource.uncommitted = capacity
		resource.wait_queue = PriorityQueue{Process,Int64}()
		resource.active_set = Dict{Process, Int64}()
		resource.preempt_set = Dict{Process, Float64}()
		resource.monitored = monitored
		if monitored
			resource.wait_monitor = Monitor{Int64}("Wait monitor of $name")
			register(simulation, resource.wait_monitor)
			resource.activity_monitor = Monitor{Int64}("Activity monitor of $name")
			register(simulation, resource.activity_monitor)
		end
		return resource
	end
end

function occupied(resource::Resource)
	return capacity - uncommitted
end

function acquired(process::Process, resource::Resource)
	result = true
	if ! has(resource.active_set, process)
		delete!(resource.wait_queue, process)
		if resource.monitored
			observe(resource.wait_monitor, now(process), length(resource.wait_queue))
		end
		result = false
	end
	return result
end

function request(process::Process, resource::Resource, priority::Int64, preempt::Bool, waittime::Float64, signals::Set{Signal}, renege::Bool)
	cancel(process)
	if resource.uncommitted == 0
		min_priority, min_index = findmin(values(resource.active_set))
		if preempt && priority > min_priority
			min_process = keys(resource.active_set)[min_index]
			delete!(resource.active_set, min_process)
			unshift!(resource.wait_queue, min_process, min_priority)
			resource.preempt_set[min_process] = min_process.next_event.time - now(process)
			cancel(min_process)
			resource.active_set[process] = priority
			post(process.simulation, process, now(process), true)
		else
			push!(resource.wait_queue, process, priority)
			if renege
				if waittime < Inf
					post(process.simulation, process, now(process)+waittime, true)
				else
					return wait(process, signals)
				end
			end
		end
		if resource.monitored
			observe(resource.wait_monitor, now(process), length(resource.wait_queue))
		end
	else
		resource.uncommitted -= 1
		resource.active_set[process] = priority
		if resource.monitored
			observe(resource.activity_monitor, now(process), length(resource.active_set))
		end
		post(process.simulation, process, now(process), true)
	end
	produce(true)
end

function request(process::Process, resource::Resource, priority::Int64, preempt::Bool, waittime::Float64)
	signals = Set{Signal}()
	request(process, resource, priority, preempt, waittime, signals, true)
end

function request(process::Process, resource::Resource, priority::Int64, preempt::Bool, signals::Set{Signal})
	return request(process, resource, priority, preempt, Inf, signals, true)
end

function request(process::Process, resource::Resource, priority::Int64, waittime::Float64)
	signals = Set{Signal}()
	request(process, resource, priority, false, waittime, signals, true)
end

function request(process::Process, resource::Resource, priority::Int64, signals::Set{Signal})
	return request(process, resource, priority, false, Inf, signals, true)
end

function request(process::Process, resource::Resource, priority::Int64, preempt::Bool)
	signals = Set{Signal}()
	request(process, resource, priority, preempt, Inf, signals, false)
end

function request(process::Process, resource::Resource, priority::Int64)
	return request(process, resource, priority, false, Inf, Set{Signal}(), false)
end

function request(process::Process, resource::Resource, waittime::Float64)
	signals = Set{Signal}()
	request(process, resource, 0, false, waittime, signals, true)
end

function request(process::Process, resource::Resource, signals::Set{Signal})
	return request(process, resource, 0, false, Inf, signals, true)
end

function request(process::Process, resource::Resource)
	signals = Set{Signal}()
	request(process, resource, 0, false, Inf, signals, false)
	return signals
end

function release(process::Process, resource::Resource)
	resource.uncommitted += 1
	delete!(resource.active_set, process)
	if resource.monitored
		observe(resource.activity_monitor, now(process), length(resource.active_set))
	end
	if length(resource.wait_queue) > 0
		new_process, new_priority = shift!(resource.wait_queue)
		resource.uncommitted -= 1
		resource.active_set[new_process] = new_priority
		if resource.monitored
			observe(resource.wait_monitor, now(process), length(resource.wait_queue))
			observe(resource.activity_monitor, now(process), length(resource.active_set))
		end
		if has(resource.preempt_set, new_process)
			post(new_process.simulation, new_process, now(new_process)+resource.preempt_set[new_process], true)
			delete!(resource.preempt_set, new_process)
		else
			post(new_process.simulation, new_process, now(new_process), true)
		end
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

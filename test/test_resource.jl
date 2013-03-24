require("../src/SimJulia.jl")
using SimJulia
using Distributions

function customer(process::Process, resource::Resource, monitor::Monitor)
	exponential_distribution = Exponential(8.0)
	arrive = now(process)
	println("$arrive, $process: Here I am")
	produce(request(process, resource))
	wait = now(process) - arrive
	observe(monitor, now(process), wait)
	println("$(now(process)), $process: Waited $wait")
	produce(hold(process, rand(exponential_distribution)))
	wait = now(process) - arrive
	println("$(now(process)), $process: Finished in $wait")
	produce(release(process, resource))
end

function source(process::Process, resource::Resource, monitor::Monitor)
	exponential_distribution = Exponential(10.0)
	i = 1
	while true
		customer_process = Process(process.simulation, "Customer $i")
		activate(customer_process, now(process), customer, resource, monitor)
		produce(hold(process, rand(exponential_distribution)))
		i += 1
	end
end

simulation = Simulation(uint(16))
source_process = Process(simulation, "Source")
counter_resource = Resource(simulation, "Counter", uint(1), true)
waiting_monitor = Monitor{Float64}("Wait")
activate(source_process, 0.0, source, counter_resource, waiting_monitor)
run(simulation, 100.0)
println(mean(wait_monitor(counter_resource)))
println(mean(activity_monitor(counter_resource)))
println(mean(waiting_monitor))
trace(waiting_monitor)

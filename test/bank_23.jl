using Distributions
using SimJulia

# Model components

function visit(customer::Process, time_in_bank::Float64, clerk::Resource, priority::Int64)
	arrive = now(customer)
	number_waiting = length(clerk.wait_queue)
	@printf("%8.3f %s: Queue is %d on arrival\n", arrive, customer, number_waiting)
	request(customer, clerk, priority, true)
	wait = now(customer) - arrive
	@printf("%8.3f %s: Waited %6.3f\n", now(customer), customer, wait)
	hold(customer, time_in_bank)
	release(customer, clerk)
	@printf("%8.3f %s: Completed\n", now(customer), customer)
end

function generate(source::Process, number::Int64, mean_time_between_arrivals::Float64, clerk::Resource)
	d = Exponential(mean_time_between_arrivals)
	for i = 1:number
		c = Process(simulation(source), @sprintf("Customer%02d", i))
		activate(c, now(source), visit, 12.0, clerk, 0)
		t = rand(d)
		hold(source, t)
	end
end

# Experiment data

max_number = 5
max_time = 400.0
mean_time_between_arrivals = 10.0
theseed = 989898

# Model/Experiment

srand(theseed)
sim = Simulation(uint(16))
k = Resource(sim, "Counter", uint(1), false)
s = Process(sim, "Source")
activate(s, 0.0, generate, max_number, mean_time_between_arrivals, k)
ben = Process(sim, "Ben")
activate(ben, 23.0, visit, 12.0, k, 100)
run(sim, max_time)

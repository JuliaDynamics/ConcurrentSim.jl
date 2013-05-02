using Distributions
using SimJulia

# Model components


function visit(customer::Process, time_in_bank::Float64, counter::Resource, max_in_queue::Int)
	arrive = now(customer)
	@printf("%8.4f %s: Here I am\n", arrive, customer)
	if length(counter.wait_queue) < max_in_queue
		request(customer, counter)
		wait = now(customer) - arrive
		@printf("%8.4f %s: Waited %6.3f\n", now(customer), customer, wait)
		hold(customer, time_in_bank)
		release(customer, counter)
		@printf("%8.4f %s: Finished\n", now(customer), customer)
	else
		@printf("%8.4f %s: BALKING\n", now(customer), customer)
	end
end

function generate(source::Process, number::Int, mean_time_between_arrivals::Float64, mean_time_in_bank::Float64, counter::Resource, max_in_queue::Int)
	d_tba = Exponential(mean_time_between_arrivals)
	d_tib = Exponential(mean_time_in_bank)
	for i = 1:number
		c = Process(simulation(source), @sprintf("Customer%02d", i))
		tib = rand(d_tib)
		activate(c, now(source), visit, tib, counter, max_in_queue)
		tba = rand(d_tba)
		hold(source, tba)
	end
end

function number_in_system(counter::Resource)
	return length(counter.active_set) + length(counter.wait_queue)
end

# Experiment data

max_number = 8
max_time = 4000.0
max_in_queue = 1
mean_time_between_arrivals = 10.0
mean_time_in_bank = 12.0
number_of_counters = 1
theseed = 212121

# Model/Experiment

srand(theseed)
sim = Simulation(uint(16))
k = Resource(sim, "Counter", uint(1), false)
s = Process(sim, "Source")
activate(s, 0.0, generate, max_number, mean_time_between_arrivals, mean_time_in_bank, k, max_in_queue)
run(sim, max_time)

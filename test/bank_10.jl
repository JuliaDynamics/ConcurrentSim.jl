using Distributions
using SimJulia

# Model components

function visit(customer::Process, time_in_bank::Float64, counters::Vector{Resource})
	arrive = now(customer)
	number_in_counters = Array(Int64, length(counters))
	for i = 1:length(counters)
		number_in_counters[i] = number_in_system(counters[i])
	end
	@printf("%8.3f %s: Here I am. %s\n", arrive, customer, number_in_counters)
	choice = indmin(number_in_counters)
	request(customer, counters[choice])
	wait = now(customer) - arrive
	@printf("%8.3f %s: Waited %6.3f\n", now(customer), customer, wait)
	hold(customer, time_in_bank)
	release(customer, counters[choice])
	@printf("%8.3f %s: Finished\n", now(customer), customer)
end

function generate(source::Process, number::Int64, mean_time_between_arrivals::Float64, mean_time_in_bank::Float64, counters::Vector{Resource})
	d_tba = Exponential(mean_time_between_arrivals)
	d_tib = Exponential(mean_time_in_bank)
	for i = 1:number
		c = Process(simulation(source), @sprintf("Customer%02d", i))
		tib = rand(d_tib)
		activate(c, now(source), visit, tib, counters)
		tba = rand(d_tba)
		hold(source, tba)
	end
end

function number_in_system(counter::Resource)
	return length(counter.active_set) + length(counter.wait_queue)
end

# Experiment data

max_number = 5
max_time = 400.0
mean_time_between_arrivals = 10.0
mean_time_in_bank = 12.0
number_of_counters = 2
theseed = 787878

# Model/Experiment

srand(theseed)
sim = Simulation(uint(16))
k1 = Resource(sim, "Clerk1", uint(1), false)
k2 = Resource(sim, "Clerk2", uint(1), false)
s = Process(sim, "Source")
activate(s, 0.0, generate, max_number, mean_time_between_arrivals, mean_time_in_bank, [k1, k2])
run(sim, max_time)

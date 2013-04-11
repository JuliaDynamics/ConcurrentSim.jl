using Distributions
using SimJulia

# Model components

function visit(customer::Process, time_in_bank::Float64)
	@printf("%7.4f %s: Here I am\n", now(customer), customer)
	hold(customer, time_in_bank)
	@printf("%7.4f %s: I must leave\n", now(customer), customer)
end

function generate(source::Process, number::Int64, mean_time_between_arrivals::Float64)
	d = Exponential(mean_time_between_arrivals)
	for i = 1:number
		c = Process(simulation(source), @sprintf("Customer%02d", i))
		activate(c, now(source), visit, 12.0)
		t = rand(d)
		hold(source, t)
	end
end

# Experiment data

max_number = 5
max_time = 400.0
mean_time_between_arrivals = 10.0
theseed = 99999

# Model/Experiment

srand(theseed)
sim = Simulation(uint(16))
s = Process(sim, "Source")
activate(s, 0.0, generate, max_number, mean_time_between_arrivals)
run(sim, max_time)

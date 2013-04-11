using Distributions
using SimJulia

# Model components

function visit(customer::Process, time_in_bank::Float64)
	println("$(now(customer)) $customer Here I am")
	hold(customer, time_in_bank)
	println("$(now(customer)) $customer I must leave")
end

# Experiment data

max_time = 100.0
time_in_bank = 10.0
theseed = 99999

# Model/Experiment

srand(theseed)
sim = Simulation(uint(16))
c = Process(sim, "Ben")
d = Exponential(5.0)
t = rand(d)
activate(c, t, visit, time_in_bank)
run(sim, max_time)

using SimJulia

# Model components

function visit(customer::Process, time_in_bank::Float64)
	@printf("%7.4f %s: Here I am\n", now(customer), customer)
	hold(customer, time_in_bank)
	@printf("%7.4f %s: I must leave\n", now(customer), customer)
end

# Experiment data

max_time = 400.0

# Model/Experiment

sim = Simulation(uint(16))
c1 = Process(sim, "Ben")
activate(c1, 5.0, visit, 10.0)
c2 = Process(sim, "Christel")
activate(c2, 2.0, visit, 7.0)
c3 = Process(sim, "Ann")
activate(c3, 12.0, visit, 20.0)
run(sim, max_time)

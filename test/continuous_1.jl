using SimJulia

function dynamics(variables::Vector{Variable})
	prey = variables[1]
	predator = variables[2]
	prey.rate = (-0.3 + 3.0e-7 * prey.state) * predator.state
	predator.rate = (0.3 - 3.0e-4 * predator.state) * prey.state
end

function predator_prey(process::Process)
	prey = Variable(1000.0)
	predator = Variable(100000.0)
	add_variables(simulation(process), [prey, predator], dynamics)
	hold(process, 100.0)
	println(prey.rate)
end

sim = Simulation(uint(16))
pp = Process(sim, "Predator Prey")
activate(pp, 0.0, predator_prey)
run_continuous(sim, 200.0)
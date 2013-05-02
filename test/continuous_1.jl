using SimJulia

function dynamics(time::Float64, variables::Vector{Variable})
	prey = variables[1]
	predator = variables[2]
	predator.rate = (1.0 - prey.state / 200.0) * predator.state
	prey.rate = -(1.0 - predator.state / 300.0) * prey.state 
end

function print_variables(process::Process, variables::Vector{Variable})
	prey = variables[1]
	predator = variables[2]
	while true
		@printf("%6.3f: %3.0f %3.0f\n", now(process), state(prey), state(predator))
		hold(process, 1.0)
	end
end

function predator_prey(process::Process)
	prey = Variable(100.0)
	predator = Variable(400.0)
	add_variables(simulation(process), [prey, predator], dynamics)
	monitor = Process(simulation(process), "Monitor")
	activate(monitor, now(process), print_variables, [prey, predator])
	waituntil(process, ()->return(prey.rate > 0))
	@printf("%6.3f: Prey rate positif\n", now(process))
	waituntil(process, ()->return(prey.rate <= 0))
	cycle_start = now(process)
	@printf("%6.3f: Prey rate negatif\n", cycle_start)
	waituntil(process, ()->return(prey.rate > 0))
	@printf("%6.3f: Prey rate positif\n", now(process))
	waituntil(process, ()->return(prey.rate <= 0))
	cycle_stop = now(process)
	@printf("%6.3f: Prey rate negatif\n", cycle_stop)
	hold(process, 1.0)
	remove_variables(simulation(process), [prey, predator], dynamics)
	println("period = $cycle_stop - $cycle_start = $(cycle_stop - cycle_start)")
end

sim = Simulation(uint(16))
pp = Process(sim, "Predator Prey")
activate(pp, 0.0, predator_prey)
run(sim, 10.0)
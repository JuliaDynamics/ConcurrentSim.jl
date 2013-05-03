using SimJulia

function rocket_motion(time::Float64, variables::Vector{Variable}, mass_flow::Float64, flow_velocity::Float64, area::Float64)
	mass = variables[1]
	velocity = variables[2]
	altitude = variables[3]
	mass.rate = -mass_flow
	thrust = mass_flow * flow_velocity
	drag = area * 0.00119 * exp(-altitude.state / 24000.0) * velocity.state ^ 2.0
	gravity = mass.state * 32.17 / (1.0 + altitude.state / 20908800.0) ^ 2.0
	velocity.rate = (thrust - drag - gravity) / mass.state
	altitude.rate = velocity.state
end

function print_variables(process::Process, variables::Vector{Variable})
	mass = variables[1]
	velocity = variables[2]
	altitude = variables[3]
	while true
		@printf("%8.3f: mass = %6.0f, velocity = %5.0f, altitude = %7.0f\n", now(process), state(mass), state(velocity), state(altitude))
		hold(process, 50.0)
	end
end

function three_stage_rocket(process::Process)
	mass = Variable(189162.0)
	velocity = Variable(0.0)
	altitude = Variable(0.0)
	variables = [mass, velocity, altitude]
	monitor = Process(simulation(process), "Monitor")
	activate(monitor, now(process), print_variables, variables)
	func = (time::Float64, variables::Vector{Variable})->rocket_motion(time, variables, 930.0, 8060.0, 510.0)
	add_variables(simulation(process), [mass, velocity, altitude], func)
	waituntil(process, ()->return altitude.state > 25000.0)
	@printf("%8.3f: Reached %8.2f km!\n", now(process), altitude.state)
	remove_variables(simulation(process), [mass, velocity, altitude], func)
	mass.state = 40342.0
	func = (time::Float64, variables::Vector{Variable})->rocket_motion(time, variables, 81.49, 13805.0, 460.0)
	add_variables(simulation(process), [mass, velocity, altitude], func)
	waituntil(process, ()->return altitude.state > 800000.0)
	@printf("%8.3f: Reached %8.2f km!\n", now(process), altitude.state)
	remove_variables(simulation(process), [mass, velocity, altitude], func)
	mass.state = 8137.0
	func = (time::Float64, variables::Vector{Variable})->rocket_motion(time, variables, 14.75, 15250.0, 360.0)
	add_variables(simulation(process), [mass, velocity, altitude], func)
	hold(process, 479.0)
	remove_variables(simulation(process), [mass, velocity, altitude], func)
end

sim = Simulation(uint(16))
tsr = Process(sim, "Three Stage Rocket")
activate(tsr, 0.0, three_stage_rocket)
run(sim, 900.0)
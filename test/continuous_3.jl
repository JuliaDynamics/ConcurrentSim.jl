using SimJulia
using Distributions

type House
	name::ASCIIString
	c::Float64
	material::Float64
	travel_time::Float64
	extinguishrate::Float64
	fire_stopped::Signal
	size::Variable
end

function burning(time::Float64, variables::Vector{Variable}, house::House)
	size = variables[1]
	damage = variables[2]
	size.rate = house.c * size.state - house.extinguishrate
	damage.rate = size.state
end

function house_on_fire(process::Process, fire_signal::Signal, fire_station::Resource, damage_monitor::Monitor{Float64})
	println("$(now(process)): new fire in $process")
	fire_stopped = Signal("Fire stopped")
	house = House("$process", 0.01 + 0.05 * rand(), 100.0 + 500.0 * rand(), 5.0 + 10.0 * rand(), 0.0, fire_stopped, Variable(5.0 * rand()))
	damage = Variable(house.size.state)
	variables = [house.size, damage]
	burn = (time::Float64, variables::Vector{Variable})->burning(time, variables, house)
	add_variables(simulation(process), [house.size, damage], burn)
	request(process, fire_station)
	fire(fire_signal, house)
	waituntil(process, ()->return house.size.state <= 0.0 || damage.state >= house.material)
	fire(fire_stopped)
	release(process, fire_station)
	remove_variables(simulation(process), [house.size, damage], burn)
	observe(damage_monitor, now(process), min(damage.state, house.material) / house.material)
	println("$(now(process)): fire stopped in $process")
end

function incendary(process::Process, fire_signal::Signal, fire_station::Resource, damage_monitor::Monitor{Float64})
	dist = Exponential(6.0 * 60.0)
	i = 1
	while true
		hold(process, rand(dist))
		new_fire = Process(simulation(process), "House $i")
		activate(new_fire, now(process), house_on_fire, fire_signal, fire_station, damage_monitor)
		i += 1
	end
end

function fire_engine(process::Process, fire_signal::Signal, fire_station::Resource)
	while true
		queue(process, fire_signal)
		println("$(now(process)): $process leaves base")
		house = param(fire_signal)
		hold(process, house.travel_time)
		println("$(now(process)): $process starts extinguishing $(house.name)")
		house.extinguishrate += 10.0
		if house.size.rate > house.extinguishrate
			println("$(now(process)): fire in $(house.name) to big for $process")
			request(process, fire_station)
			fire(fire_signal, house)
			wait(process, house.fire_stopped)
			release(process, house)
		else
			wait(process, house.fire_stopped)
		end
		println("$(now(process)): fire in $(house.name) controlled by $process")
		hold(process, house.travel_time)
		println("$(now(process)): $process back to base")
	end
end


sim = Simulation(uint(256))
fire_signal = Signal("Fire")
fire_station = Resource(sim, "Firestation", uint(3), false)
damage_monitor = Monitor{Float64}("Damage monitor")
register(sim, damage_monitor)
fire_engine_1 = Process(sim, "Fire engine 1")
fire_engine_2 = Process(sim, "Fire engine 2")
fire_engine_3 = Process(sim, "Fire engine 3")
activate(fire_engine_1, 0.0, fire_engine, fire_signal, fire_station)
activate(fire_engine_2, 0.0, fire_engine, fire_signal, fire_station)
activate(fire_engine_3, 0.0, fire_engine, fire_signal, fire_station)
fire_generator = Process(sim, "Incendary")
activate(fire_generator, 0.0, incendary, fire_signal, fire_station, damage_monitor)
run(sim, 30.0*24.0*60.0)
report(damage_monitor, 0.0, 1.0, uint(20))

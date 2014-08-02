using SimJulia
using Distributions

type House
	c::Float64
	material::Float64
	travel_time::Float64
	extinguishrate::Float64
end

type FireEngine
	capacity::Float64
end

function burning(time::Float64, variables::Vector{Variable}, house::House)
	size = variables[1]
	damage = variables[2]
	size.rate = house.c * size.state - house.extinguishrate
	damage.rate = size.state
end

function house_on_fire(process::Process, fire_station::Store{FireEngine}, damage_monitor::Monitor{Float64})
	@printf("%5.0f: new fire in %s\n", now(process), "$process")
	house = House(0.01 + 0.05 * rand(), 100.0 + 500.0 * rand(), 5.0 + 10.0 * rand(), 0.0)
	size = Variable(5.0 * rand())
	damage = Variable(size.state)
	variables = [size, damage]
	burn = (time::Float64, variables::Vector{Variable})->burning(time, variables, house)
	start(simulation(process), variables, burn)
	engines = FireEngine[]
	SimJulia.get(process, fire_station, uint(1))
	engine = got(process, fire_station)[1]
	@printf("%5.0f: first engine leaves station for %s\n", now(process), "$process")
	push!(engines, engine)
	hold(process, house.travel_time)
	@printf("%5.0f: first engine arrives to %s\n", now(process), "$process")
	house.extinguishrate += engine.capacity
	while size.rate > house.extinguishrate && length(engines) < 3
		get(process, fire_station, uint(1))
		engine = got(process, fire_station)[1]
		@printf("%5.0f: next engine leaves station for %s\n", now(process), "$process")
		push!(engines, engine)
		hold(process, house.travel_time)
		@printf("%5.0f: next engine arrives to %s\n", now(process), "$process")
		house.extinguishrate += engine.capacity
	end
	waituntil(process, ()->return size.state <= 0.0 || damage.state >= house.material)
	stop(simulation(process), [size, damage], burn)
	observe(damage_monitor, now(process), 100.0 * min(damage.state, house.material) / house.material)
	@printf("%5.0f: fire stopped in %s\n", now(process), "$process")
	hold(process, house.travel_time)
	put(process, fire_station, engines)
end

function incendary(process::Process, fire_station::Store{FireEngine}, damage_monitor::Monitor{Float64})
	dist = Exponential(6.0 * 60.0)
	i = 1
	while true
		hold(process, rand(dist))
		new_fire = Process(simulation(process), "House $i")
		activate(new_fire, now(process), house_on_fire, fire_station, damage_monitor)
		i += 1
	end
end

sim = Simulation(uint(256))
fire_station = Store{FireEngine}(sim, "Firestation", 3, [FireEngine(1.0), FireEngine(1.0), FireEngine(1.0)], false)
damage_monitor = Monitor{Float64}("Percentage damage")
register(sim, damage_monitor)
fire_generator = Process(sim, "Incendary")
activate(fire_generator, 0.0, incendary, fire_station, damage_monitor)
run(sim, 30.0*24.0*60.0)
report(damage_monitor, 0.0, 100.0, uint(20))

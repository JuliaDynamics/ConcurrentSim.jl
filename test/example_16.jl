using SimJulia

function life_cycle_car(car::Process, waiting_cars::Store)
	signal = Signal("$car")
	put(car, waiting_cars, [signal])
	wait(car, signal)
	which_wash = param(signal)
	println("$(now(car)) $car is done by $which_wash")
end

function generate_cars(process::Process, waiting_cars::Store)
	i = 0
	while true
		hold(process, 2.0)
		car = Process(simulation(process), "Car $i")
		activate(car, now(process), life_cycle_car, waiting_cars)
		i += 1
	end
end

function wash_car(process::Process, waiting_cars::Store)
	while true
		get(process, waiting_cars, uint(1))
		signal = got(process, waiting_cars)[1]
		hold(process, 5.0)
		fire(signal, process)
	end
end

sim = Simulation(uint(16))
waiting_cars = Store{Signal}(sim, "Waiting_cars", 40, Signal[], true)
for i = 1:4
	car = Process(sim, "Car -$i")
	activate(car, 0.0, life_cycle_car, waiting_cars)
end
for i = 1:2
	cw = Process(sim, "Carwash $i")
	activate(cw, 0.0, wash_car, waiting_cars)
end
cg = Process(sim, "Cargenerator")
activate(cg, 0.0, generate_cars, waiting_cars)
run(sim, 30.0)
println("Cars waiting: $(buffer(waiting_cars))")

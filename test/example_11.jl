using SimJulia

function park(process::Process, parking_lot::Resource, patience::Float64, park_time::Float64)
	println("$(now(process)): $process enters the parking lot and starts searching")
	request(process, parking_lot, patience)
	if acquired(process, parking_lot)
		println("$(now(process)): $process has found a parking spot")
		hold(process, park_time)
		release(process, parking_lot)
		println("$(now(process)): $process leaves the parking lot")
	else
		println("$(now(process)): $process has not found a parking spot and leaves the parking lot")
	end
end

function arrive(process::Process, interval::Float64)
	parking_lot = Resource(sim, "Parking_lot", uint(10), false)
	i = 1
	while true
		car = Process(sim, "Car $i")
		activate(car, now(process), park, parking_lot, 5.0, 60.0)
		i = i + 1
		hold(process, interval)
	end
end

sim = Simulation(uint(16))
cars = Process(sim, "Arrivals")
activate(cars, 0.0, arrive, 4.0)
run(sim, 100.0)

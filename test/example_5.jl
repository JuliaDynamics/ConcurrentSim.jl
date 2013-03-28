require("../src/SimJulia.jl")
using SimJulia

function operate(bus::Process, repairduration::Float64, triplength::Float64, br::Process)
	tripleft = triplength
	while tripleft > 0.0
		produce(hold(bus, tripleft))
		if interrupted(bus)
			println("$(bus.interrupt_cause) at $(now(bus))")
			tripleft = bus.interrupt_left
			interrupt_reset(bus)
			reactivate(br, now(bus)+repairduration)
			produce(hold(bus, repairduration))
			println("Bus repaired at $(now(bus))")
		else
			break
		end
	end
	println("Bus has arrived at $(now(bus))")
end

function break_bus(br::Process, interval::Float64, bus::Process)
	while true
		produce(hold(br, interval))
		if terminated(bus)
			break
		end
		interrupt(bus, br)
		produce(sleep(br))
	end
end

sim = Simulation(uint(16))
b = Process(sim, "Bus")
br = Process(sim, "Breakdown")
activate(b, 0.0, operate, 20.0, 1000.0, br)
activate(br, 0.0, break_bus, 300.0, b)
run(sim, 4000.0)
println("JuliaSim: No more events at time $(now(b))")

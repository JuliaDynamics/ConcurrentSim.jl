using Base.Test
using SimJulia

function deliver(process::Process, stock::Level)
	lead = 10.0
	delivery = 10.0
	while true
		put(process, stock, delivery)
		println("at $(now(process)), add $delivery, now amount = $(amount(stock))")
		hold(process, lead)
	end
end

function demand(process::Process, stock::Level)
	delay = 1.0
	while true
		hold(process, delay)
		dd = 0.2*randn()+1.2
		ds = dd - amount(stock)
		if ds > 0.0
			SimJulia.get(process, stock, amount(stock))
			println("at $(now(process)), demand = $dd, shortfall = -$ds")
		else
			SimJulia.get(process, stock, dd)
			println("at $(now(process)), demand = $dd, now amount = $(amount(stock))")
		end
	end
end

sim = Simulation(uint(16))
stock = Level(sim, "Stock", Inf, 0.0, true)
offeror = Process(sim, "Offeror")
activate(offeror, 0.0, deliver, stock)
requestor = Process(sim, "Requestor")
activate(requestor, 0.0, demand, stock)

println("after")
run(sim, 49.9)
println("Average stock = $(mean(buffer_monitor(stock)))")

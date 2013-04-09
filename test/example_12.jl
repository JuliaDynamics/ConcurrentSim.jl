using Test
using SimJulia

function visit(visitor::Process, seats::Resource, signals::Set{Signal})
	occured_signals = request(visitor, seats, signals)
	if acquired(visitor, seats)
		hold(visitor, 150.0 - now(visitor))
		release(visitor, seats)
	else
		println("$(now(visitor)) $visitor: Who needs to see this silly movie anyhow? $(collect(occured_signals)[1])")
	end
end

function generate(process::Process, seats::Resource, sold_out::Signal, too_late::Signal)
	signals = Set{Signal}()
	add!(signals, sold_out)
	add!(signals, too_late)
	i = 1
	while true
		person = Process(simulation(process), "Person $i")
		activate(person,now(process), visit, seats, signals)
		if i == 120
			fire(sold_out)
			return
		end
		i += 1
		hold(process, rand())
	end
end

function doors_closing(process::Process, too_late::Signal)
	fire(too_late)
end

sim = Simulation(uint(256))
seats = Resource(sim, "Seats", uint(100), false)
sold_out = Signal("Sold out")
too_late = Signal("Too late")
visitor_generator = Process(sim, "Visitor generator")
activate(visitor_generator, 0.0, generate, seats, sold_out, too_late)
closing = Process(sim, "Closed doors")
activate(closing, 60.0, doors_closing, too_late)
run(sim, 150.0)
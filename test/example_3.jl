using SimJulia

function execute(firework::Process)
	println("$(now(firework)): Firework launched")
	hold(firework, 10.0)
	for i = 1:10
		hold(firework, 1.0)
		println("$(now(firework)): Tick")
	end
	hold(firework, 10.0)
	println("$(now(firework)): Boom!!")
end

sim = Simulation(uint(16))
f = Process(sim, "Firework")
activate(f, 0.0, execute)
run(sim, 100.0)

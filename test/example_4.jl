require("../src/SimJulia.jl")
using SimJulia

function buy(customer::Process, budget::Float64)
	println("$(now(customer)) $customer: Here I am at the shops, I have $(round(budget)) to spend")
	t = 5.0
	for i = 1:4
		if budget < 10.0
			break
		end
		hold(customer, t)
		println("$(now(customer)) $customer: I just bought something")
		budget -= 10.0
	end
	println("$(now(customer)) $customer: All I have left is $(round(budget)), I am going home")
end

function execute(source::Process, finish::Float64)
	i = 1
	while now(source) < finish
		c = Process(source.simulation, "Customer$(i)")
		activate(c, now(source), buy, round(100.0*rand()))
		hold(source, 10.0)
		i = i+1
	end
end

sim = Simulation(uint(16))
g = Process(sim, "Source")
activate(g, 0.0, execute, 30.0)
run(sim, 100.0)

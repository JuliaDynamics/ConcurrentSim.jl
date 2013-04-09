using Test
using SimJulia

function buy(customer::Process, budget::Float64)
	println("$customer: Here I am at the shops")
	t = 5.0
	for i = 1:4
		hold(customer, t)
		println("$customer: I just bought something")
		budget -= 10.0
	end
	println("$customer: All I have left is $budget, I am going home")
end

sim = Simulation(uint(16))
c = Process(sim, "Evelyn")
activate(c, 10.0, buy, 100.0)
run(sim, 100.0)

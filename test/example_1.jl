using Base.Test
using SimJulia

function go(process::Process)
	println("$(now(process)) $process Starting")
	hold(process,100.0)
	println("$(now(process)) $process Arrived")
end

sim = Simulation(uint(16))
p1 = Process(sim, "1")
activate(p1, 0.0, go)
p2 = Process(sim, "2")
activate(p2, 6.0, go)
run(sim, 200.0)
println("Current time is now $(now(p1))")

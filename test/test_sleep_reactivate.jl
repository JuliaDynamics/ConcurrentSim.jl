require("../src/SimJulia.jl")
using SimJulia

function hello_task(process::Process, n::Uint64)
	for i = 1:n
		println("$(now(process)): Hello $i")
		produce(sleep(process))
	end
end

function reactivate_task(process::Process, hello::Process)
	while passive(hello)
		println("$(now(process)): Hello is sleeping. Reactivate in 5s!")
		reactivate(hello, now(process)+5.0)
		produce(hold(process, 30.0))
	end
	if terminated(hello)
		println("$(now(process)): Hello is terminated.")
	end
end

simulation = Simulation(uint(16))
println("Simulation created")
hello_process = Process(simulation, "Hello")
reactivate_process = Process(simulation, "Reactivate")
println("Processes created")
activate(hello_process, 0.0, hello_task, uint(5))
activate(reactivate_process, 30.0, reactivate_task, hello_process)
println("Processes activated")
println("Simulation started")
run(simulation, 1000.0)
println("Simulation finished")

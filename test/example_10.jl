using Base.Test
using SimJulia

function get_served(client::Process, serv_time::Float64, priority::Int64, my_server::Resource)
	println("$client requests 1 unit at t=$(now(client))")
	request(client, my_server, priority, true)
	hold(client, serv_time)
	release(client, my_server)
	println("$client done at t=$(now(client))")
end

sim = Simulation(uint(16))
c1 = Process(sim, "c1")
c2 = Process(sim, "c2")
my_server = Resource(sim, "my server", uint(1), false)
activate(c1, 0.0, get_served, 100.0, 1, my_server)
activate(c2, 50.0, get_served, 100.0, 9, my_server)
run(sim, 500.0)
using Test
using SimJulia

function get_served(client::Process, serv_time::Float64, my_server::Resource, in_clients::Vector{Process}, out_clients::Vector{Process})
	push!(in_clients, client)
	println("$client requests 1 unit at t = $(now(client))")
	request(client, my_server)
	hold(client, serv_time)
	release(client, my_server)
	println("$client done at t = $(now(client))")
	push!(out_clients, client)
end


in_clients = Process[]
out_clients = Process[]
sim = Simulation(uint(16))
server = Resource(sim, "My server", uint(2), false)
c1 = Process(sim, "c1")
c2 = Process(sim, "c2")
c3 = Process(sim, "c3")
c4 = Process(sim, "c4")
c5 = Process(sim, "c5")
c6 = Process(sim, "c6")
activate(c1, 0.0, get_served, 100.0, server, in_clients, out_clients)
activate(c2, 0.0, get_served, 100.0, server, in_clients, out_clients)
activate(c3, 0.0, get_served, 100.0, server, in_clients, out_clients)
activate(c4, 0.0, get_served, 100.0, server, in_clients, out_clients)
activate(c5, 0.0, get_served, 100.0, server, in_clients, out_clients)
activate(c6, 0.0, get_served, 100.0, server, in_clients, out_clients)
run(sim, 500.0)
println("Request order: $in_clients")
println("Service order: $out_clients")
using SimJulia

function generate(process::Process, lambda::Float64)
	for i = 1:1000
		wait = -log(rand())/lambda
		observe(monitor, now(process), wait)
		hold(process, wait)
	end
end

sim = Simulation(uint(16))
monitor = Monitor{Float64}("my monitor")
register(sim, monitor)
observer = Process(sim, "Observer")
activate(observer, 0.0, generate, 0.1)
run(sim, 10000.0)
h = histogram(monitor, 0.0, 20.0, uint(30))
c = count(monitor)
println("Histogram for $monitor:")
println("Number of observations: $c")
s = h[1]
println("       wait time (s) < 0.0: $(h[1])  (cum: $s/$(round(100.0*s/c,1))%)")
for i = 2:31
	s = s + h[i]
	println("$(round(20.0/30*(i-2),1)) <= wait time (s) < $(round(20.0/30*(i-1),1)): $(h[i]) (cum: $s/$(round(100.0*s/c,1))%)")
end
s = s + h[32]
println("20.0 <= wait time (s)       : $(h[12]) (cum: $s/$(round(100.0*s/c,1))%)")
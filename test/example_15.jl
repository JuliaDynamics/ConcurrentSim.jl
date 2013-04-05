using SimJulia

type Widget
	weight::Float64
end

widget_buffer = Widget[]
for i = 1:10
	push!(widget_buffer, Widget(5.0))
end
sim = Simulation(uint(16))
buffer = Store{Widget}(sim, "Buffer", uint(11), widget_buffer, true)


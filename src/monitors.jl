type Monitor{V<:Real}
	name::ASCIIString
	times::Vector{Float64}
	observations::Vector{Float64}
	function Monitor(name::ASCIIString)
		monitor = new()
		monitor.name = name
		monitor.times = Float64[]
		monitor.observations = V[]
		return monitor
	end
end

function Monitor{V<:Real}(name::ASCIIString)
	return Monitor(name)
end

function show(io::IO, monitor::Monitor)
	print(io, monitor.name)
end

function observe{V<:Real}(monitor::Monitor{V}, time::Float64, value::V)
	push!(monitor.times, time)
	push!(monitor.observations, value)
end

function trace{V<:Real}(monitor::Monitor{V})
	for i = 1:length(monitor.times)
		println("$(monitor.times[i]): $(monitor.observations[i])")
	end
end

function mean{V<:Real}(monitor::Monitor{V})
	return mean(monitor.observations)
end

type Monitor{V<:Real}
	name::ASCIIString
	times::Vector{Float64}
	observations::Vector{V}
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

function start{V<:Real}(monitor::Monitor{V}, time::Float64)
	monitor.times = Float64[]
	monitor.observations = V[]
	push!(monitor.times, time)
	push!(monitor.observations, zero(V))
end

function stop{V<:Real}(monitor::Monitor{V}, time::Float64)
	push!(monitor.times, time)
	push!(monitor.observations, zero(V))
end

function observe{V<:Real}(monitor::Monitor{V}, time::Float64, value::V)
	len = length(monitor.times)
	if (time == monitor.times[len])
		monitor.observations[len] = value
	else
		push!(monitor.times, time)
		push!(monitor.observations, value)
	end
end

function trace{V<:Real}(monitor::Monitor{V})
	len = length(monitor.times)
	for i = 1:len-1
		println("$(monitor.times[i]): $(monitor.observations[i])")
	end
end

function count{V<:Real}(monitor::Monitor{V})
	len = length(monitor.times)
	return len-1
end

function mean{V<:Real}(monitor::Monitor{V})
	result = zero(V)
	len = length(monitor.observations)
	for i = 1:len-1
		result = result + monitor.observations[i]
	end
	return result / (len-1)
	
end

function var{V<:Real}(monitor::Monitor{V})
	result = zero(V)
	len = length(monitor.observations)
	for i = 1:len-1
		result = result + monitor.observations[i]^2
	end
	return result / (len-1) - mean(monitor)^2
end

function time_average{V<:Real}(monitor::Monitor{V})
	result = 0.0
	len = length(monitor.observations)
	for i = 1:len-1
		result = result + (monitor.times[i+1] - monitor.times[i]) * monitor.observations[i]
	end
	return result / (monitor.times[len] - monitor.times[1])
end

function histogram{V<:Real}(monitor::Monitor{V}, low::V, high::V, nbins::Uint)
	histogram = zeros(Int64, nbins+2)
	len = length(monitor.observations)
	for i = 1:len-1
		y = monitor.observations[i]
		if y < low
			histogram[1] = histogram[1] + 1
		elseif y >= high
			histogram[nbins+2] = histogram[nbins+2] + 1
		else
			n = floor(nbins * (y - low) / (high - low)) + 2
			histogram[n] =  histogram[n] + 1
		end
	end
	return histogram
end

function tseries{V<:Real}(monitor::Monitor{V})
	len = length(monitor.observations)
	return monitor.times[1:len-1]
end

function yseries{V<:Real}(monitor::Monitor{V})
	len = length(monitor.observations)
	return monitor.observations[1:len-1]
end

function start{V<:Real}(monitor::Monitor{V})
	return 1
end

function done{V<:Real}(monitor::Monitor{V}, state::Int64)
	return state == length(monitor.times)
end

function next{V<:Real}(monitor::Monitor{V}, state::Int64)
	return (monitor.times[state], monitor.observations[state]), state+1
end

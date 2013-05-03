type Monitor{V<:Real}
	name::ASCIIString
	times::Vector{Float64}
	observations::Vector{V}
	function Monitor(name::ASCIIString)
		new(name, Float64[], V[])
	end
end

function Monitor{V<:Real}(name::ASCIIString, initial_value::V)
	monitor = Monitor{V}(name)
	push!(monitor.times, 0.0)
	push!(monitor.observations, initial_value)
	return monitor
end

function show(io::IO, monitor::Monitor)
	print(io, "$(monitor.name)")
end

function reset{V<:Real}(monitor::Monitor{V}, time::Float64)
	if ! isempty(monitor.observations)
		value = monitor.observations[length(monitor.observations)]
		monitor.times = Float64[]
		monitor.observations = V[]
		push!(monitor.times, time)
		push!(monitor.observations, value)
	else
		monitor.times = Float64[]
		monitor.observations = V[]
	end
end

function stop{V<:Real}(monitor::Monitor{V}, time::Float64)
	push!(monitor.times, time)
	push!(monitor.observations, zero(V))
end

function observe{V<:Real}(monitor::Monitor{V}, time::Float64, value::V)
	len = length(monitor.times)
	if len > 0 && time == monitor.times[len]
		monitor.observations[len] = value
	else
		push!(monitor.times, time)
		push!(monitor.observations, value)
	end
end

function count(monitor::Monitor)
	len = length(monitor.times)
	return len-1
end

function min(monitor::Monitor)
	len = length(monitor.times)
	return min(monitor.observations[1:len-1])
end

function max(monitor::Monitor)
	len = length(monitor.times)
	return max(monitor.observations[1:len-1])
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

function time_average(monitor::Monitor)
	result = 0.0
	len = length(monitor.observations)
	for i = 1:len-1
		result = result + (monitor.times[i+1] - monitor.times[i]) * monitor.observations[i]
	end
	return result / (monitor.times[len] - monitor.times[1])
end

function histogram{V<:Real}(monitor::Monitor{V}, low::V, high::V, nbins::Uint)
	histogram = zeros(Int, nbins+2)
	len = length(monitor.observations)
	for i = 1:len-1
		y = monitor.observations[i]
		if y <= low
			histogram[1] = histogram[1] + 1
		elseif y > high
			histogram[nbins+2] = histogram[nbins+2] + 1
		else
			n = floor(nbins * (y - low) / (high - low)) + 2
			histogram[n] = histogram[n] + 1
		end
	end
	return histogram
end

function report{V<:Real}(monitor::Monitor{V}, low::V, high::V, nbins::Uint)
	h = histogram(monitor, low, high, nbins)
	c = count(monitor)
	println("$monitor report")
	println("Number of observations: $c")
	println("Average: $(mean(monitor))")
	println("Sample Variance: $(var(monitor))")
	println("Minimum: $(min(monitor))")
	println("Maximum: $(max(monitor))")
	s = h[1]
	@printf("           X <= %8.2f: %6i (cum: %6i / %8.2f)\n", low, h[1], s, high*s/c)
	for i = 2:nbins+1
		s = s + h[i]
		@printf("%8.2f < X <= %8.2f: %6i (cum: %6i / %8.2f)\n", high/nbins*(i-2), high/nbins*(i-1), h[i], s, high*s/c)
	end
	s = s + h[22]
	@printf("%8.2f < X            : %6i (cum: %6i / %8.2f)\n", high, h[nbins+2], s, high*s/c)
end

function tseries(monitor::Monitor)
	len = length(monitor.observations)
	return monitor.times[1:len-1]
end

function yseries(monitor::Monitor)
	len = length(monitor.observations)
	return monitor.observations[1:len-1]
end

function collect{V}(monitor::Monitor{V})
	len = length(monitor.observations)
	result = Array((Float64, V),len-1)
	for i = 1:len-1
		result[i] = (monitor.times[i], monitor.observations[i])
	end
	return result
end

function start(monitor::Monitor)
	return 1
end

function done(monitor::Monitor, state::Int)
	return state == length(monitor.times)
end

function next(monitor::Monitor, state::Int)
	return (monitor.times[state], monitor.observations[state]), state+1
end
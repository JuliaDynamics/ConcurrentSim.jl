type Variable
	state :: Float64
	old_state :: Float64
	rate :: Float64
	function Variable(initial_state::Float64)
		new(initial_state, 0.0, 0.0)
	end
end

type Continuous
	variables :: Vector{Variable}
	derivative :: Function
end

function save_state(continuous::Continuous)
	for variable in continuous.variables
		variable.old_state = variable.state
	end
end

function compute_derivatives(continuous::Continous)
	continuous.derivative(continuous.variables)
end
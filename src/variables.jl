type Variable
	state :: Float64
	old_state :: Float64
	next_state :: Float64
	rate :: Float64
	k1 :: Float64
	k2 :: Float64
	k3 :: Float64
	k4 :: Float64
	k5 :: Float64
	ds :: Float64
	function Variable(initial_state::Float64)
		new(initial_state, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
	end
end

type Continuous
	variables :: Vector{Variable}
	derivative :: Function
end

function state(variable::Variable)
	return variable.state
end

function save_state(variables::Set{Variable})
	for variable in variables
		variable.old_state = variable.state
	end
end

function next_state(variables::Set{Variable})
	for variable in variables
		variable.next_state = variable.state
	end
end

function previous_state(variables::Set{Variable})
	for variable in variables
		variable.state = variable.next_state
	end
end

function compute_derivatives(time::Float64, derivatives::Set{Continuous})
	for continuous in derivatives
		continuous.derivative(time, continuous.variables)
	end
end

const a21 = 1.0 / 5.0
const a31 = 3.0 / 40.0
const a32 = 9.0 / 40.0
const a41 = 44.0 / 45.0
const a42 = -56.0 / 15.0
const a43 = 32.0 / 9.0
const a51 = 19372.0 / 6561.0
const a52 = -25360.0 / 2187.0
const a53 = 64448.0 / 6561.0
const a54 = -212.0 / 729.0
const a61 = 9017.0 / 3168.0
const a62 = -355.0 / 33.0
const a63 = 46732.0 / 5247.0
const a64 = 49.0 / 176.0
const a65 = -5103.0 / 18656.
const b1 = 35.0 / 384.0
const b3 = 500.0 / 1113.0
const b4 = 125.0 / 192.0
const b5 = -2187.0 / 6784.0
const b6 = 11.0 / 84.0
const c2 = 1.0 / 5.0
const c3 = 3.0 / 10.0
const c4 = 4.0 / 5.0
const c5 = 8.0 / 9.0
const d1 = -12715105075.0 / 11282082432.0
const d3 = 87487479700.0 / 32700410799.0
const d4 = -10690763975.0 / 1880347072.0
const d5 = 701980252875.0 / 199316789632.0
const d6 = -1453857185.0 / 822651844.0
const d7 = 69997945.0 / 29380423.0
const e1 = 71.0 / 57600.0
const e3 = -71.0 / 16695.0
const e4 = 71.0 / 1920.0
const e5 = -17253.0 / 339200.0
const e6 = 22.0 / 525.0
const e7 = -1.0 / 40.0

function integrate(variables::Set{Variable}, derivatives::Set{Continuous}, last_time::Float64, dt_now::Float64, dt_full::Float64, dt_min::Float64, dt_max::Float64, max_abs_error::Float64, max_rel_error::Float64)
	h = dt_now
	dt_next = dt_now
	error_ratio = 0.0
	next_time = last_time
	for variable in variables
		variable.k1 = h * variable.rate
	end
	while true
		for variable in variables
			variable.state = variable.old_state + a21 * variable.k1
		end
		dt = c2 * h
		time = last_time + dt
		compute_derivatives(time, derivatives)
		for variable in variables
			variable.k2 = h * variable.rate
			variable.state = variable.old_state + a31 * variable.k1 + a32 * variable.k2
		end
		dt = c3 * h
		time = last_time + dt
		compute_derivatives(time, derivatives)
		for variable in variables
			variable.k3 = h * variable.rate
			variable.state = variable.old_state + a41 * variable.k1 + a42 * variable.k2 + a43 * variable.k3
		end
		dt = c4 * h
		time = last_time + dt
		compute_derivatives(time, derivatives)
		for variable in variables
			variable.k4 = h * variable.rate
			variable.state = variable.old_state + a51 * variable.k1 + a52 * variable.k2 + a53 * variable.k3 + a54 * variable.k4
		end
		dt = c5 * h
		time = last_time + dt
		compute_derivatives(time, derivatives)
		for variable in variables
			variable.k5 = h * variable.rate
			variable.state = variable.old_state + a61 * variable.k1 + a62 * variable.k2 + a63 * variable.k3 + a64 * variable.k4 + a65 * variable.k5
		end
		dt = h
		time = last_time + dt
		compute_derivatives(time, derivatives)
		for variable in variables
			variable.k2 = variable.k5
			variable.k5 = h * variable.rate
			variable.ds = b1 * variable.k1 + b3 * variable.k3 + b4 * variable.k4 + b5 * variable.k2 + b6 * variable.k5
			variable.state = variable.old_state + variable.ds
		end
		compute_derivatives(time, derivatives)
		error_ratio = 64.0
		for variable in variables
			err = abs(e1 * variable.k1 + e3 * variable.k3 + e4 * variable.k4 + e5 * variable.k2 + e6 * variable.k5 + e7 * h * variable.rate)
			tol = max_abs_error + 0.5 * max_rel_error * (abs(variable.old_state) * abs(variable.state))
			if error_ratio * err > tol
				error_ratio = tol / err
			end
			if error_ratio < 1.0
				if dt_now < dt_min
					throw("The requested integration accuracy could not be achieved!")
				end
				f = 0.0
				h = 0.5 * h
				if h < dt_min
					f = dt_min / dt_now
					dt_now = dt_min
					dt_next = dt_min
				else
					f = 0.5
					dt_now = h
					dt_next = h
				end
				h = dt_now
				next_time = last_time + dt_now
				for variable in variables
					variable.k1 = f * variable.k1
				end
				break
			end
		end
		if error_ratio >= 1.0
			break
		end
	end
	if dt_now == dt_full
		dt_next = (0.5 * error_ratio) ^ 0.2 * dt_now
		if dt_next > dt_max
			dt_next = dt_max
		elseif dt_next < dt_min
			dt_next = dt_min
		end 
	end
	return (dt_now, dt_next)
end

function prepare_interpolation(variables::Set{Variable}, dt_full::Float64)
	for variable in variables
		variable.k4 = d1 * variable.k1 + d3 * variable.k3 + d4 * variable.k4 + d5 * variable.k2 + d6 * variable.k5 + d7 * dt_full + variable.rate
		variable.k3 = - dt_full * variable.rate + 2 * variable.ds - variable.k1
		variable.k2 = variable.k1 - variable.ds
		variable.k1 = variable.ds
	end
end

function interpolate(variables::Set{Variable}, dt::Float64, dt_full::Float64)
	f = dt / dt_full
	for variable in variables
		variable.ds = f * (variable.k1 + (1-f) * (variable.k2 + f * (variable.k3 + (1-f) * variable.k4)))
		variable.state = variable.old_state + variable.ds
	end
end

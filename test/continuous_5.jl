using SimJulia

const m = 0.01
const g = 9.81
const width = 0.008
const height = 0.046
const nbr_stones = 55
const km = m * g * 0.5 * sqrt(width^2 + height^2)
const theta = m * (width^2 + height^2) / 3.0

function dynamics(time::Float64, variables::Vector{Variable}, nr::Int)
	omega = variables[1]
	phi = variables[2]
	omega.rate = km * sin(phi.state) / theta
	phi.rate = omega.state
end

function stone(process::Process, nr::Int, distance::Float64, initial_omega::Float64, phi_push::Float64, k0::Float64)
	phi = Variable(0.0)
	omega = Variable(initial_omega)
	f = (time::Float64, variables::Vector{Variable}) -> dynamics(time, variables, nr)
	start(simulation(process), [omega, phi], f)
	if nr < nbr_stones
		waituntil(process, ()->return phi.state >= phi_push)
		new_stone = Process(simulation(process), "Stone $nr")
		activate(new_stone, now(process), stone, nr + 1, distance, k0 * omega.state, phi_push, k0)
		omega.state = (1.0 - sqrt(k0)) * omega.state
	end
	waituntil(process, ()->return phi.state >= pi/2.0)
	stop(simulation(process), [omega, phi], f)
end

function game(distance::Float64)
	sim = Simulation(uint(32), 1.0e-6, 0.2, 1.0e-4, 1.0e-4)
	domino = Process(sim, "Stone 1")
	k0 = 1.0 - (distance - width)^2 / height^2
	initial_omega = height / 2.0 * 1.0e-5 / theta
	phi_push = asin((distance - width) / height)
	activate(domino, 0.0, stone, 1, distance, initial_omega, phi_push, k0)
	run(sim, 100.0)
	velocity = distance * (nbr_stones - 1) / now(domino)
	return velocity
end

function golden_section_search(f::Function, a::Float64, b::Float64, tol::Float64)
	gs = (sqrt(5.0) - 1.0) / 2.0
	x1 = b - gs * (b - a)
	y1 = f(x1)
	x2 = a + gs * (b - a)
	y2 = f(x2)
	while b - x1 > tol
		if y1 >= y2
			b = x2
			x2 = x1
			y2 = y1
			x1 = b - gs * (b - a)
			y1 = f(x1)
		else
			a = x1
			x1 = x2
			y1 = y2
			x2 = a + gs * (b - a)
			y2 = f(x2)
		end
	end
	if y1 >= y2
		return x1, y1
	end
	return x2, y2
end

d, v = golden_section_search(game, 0.008, 0.046 + 0.008, 0.001)
@printf("The maximum chain velocity %5.3f m/s is reached with a distance of %6.4f m between stones.\n", v, d)
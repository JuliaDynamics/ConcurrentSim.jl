using SimJulia

# Model components

type Automata
	size_x::Int64
	size_y::Int64
	cell_states::Matrix{Bool}
	function Automata(size_x::Int64, size_y::Int64)
		new(size_x, size_y, zeros(Bool, size_x, size_y))
	end
end

function number_active_neighbours(x::Int64, y::Int64, automata::Automata)
	nan = 0
	for i = x-1:x+1
		if i < 1
			i = automata.size_x
		elseif i > automata.size_x
			i = 1
		end
		for j = y-1:y+1
			if j < 1
				j = automata.size_y
			elseif j > automata.size_y
				j = 1
			end
			if automata.cell_states[i, j]
				nan += 1
			end
		end
	end
	if automata.cell_states[x, y]
		nan -= 1
	end
	return nan
end

function decide(self_active::Bool, nan::Int64)
	return (self_active && (nan == 2 || nan == 3)) || nan == 3
end

function life(cell::Process, x::Int64, y::Int64, automata::Automata)
	while true
		nan = number_active_neighbours(x, y, automata)
		temp = decide(automata.cell_states[x, y], nan)
		hold(cell, 0.5)
		automata.cell_states[x, y] = temp
		hold(cell, 0.5)
	end
end

function picture(show::Process, automata::Automata)
	iteration = 0
	while true
		println("Iteration $iteration")
		for i = 1:automata.size_x
			str = ""
			for j = 1:automata.size_y
				if automata.cell_states[i, j]
					str ="$str *"
				else
					str = "$str ."
				end
			end
			println(str)
		end
		println()
		hold(show, 1.0)
		iteration += 1
	end
end

# Experiment data

size = 20
max_time = 30.0

# Model/Experiment

sim = Simulation(uint(1024))
automata = Automata(size, size)
automata.cell_states[10,4] = true
automata.cell_states[11,4] = true
automata.cell_states[10,5] = true
automata.cell_states[9,5] = true
automata.cell_states[10,6] = true
automata.cell_states[6,6] = true
automata.cell_states[6,7] = true
automata.cell_states[5,6] = true
automata.cell_states[5,7] = true
automata.cell_states[5,8] = true
automata.cell_states[11,11] = true
automata.cell_states[11,12] = true
automata.cell_states[11,13] = true
automata.cell_states[11,14] = true
automata.cell_states[12,11] = true
automata.cell_states[12,12] = true
automata.cell_states[12,13] = true
automata.cell_states[12,14] = true
for i = 1:size
	for j = 1:size
		cell = Process(sim, "Cell[$i,$j]")
		activate(cell, 0.0, life, i, j, automata)
	end
end
s = Process(sim, "Show")
activate(s, 0.0, picture, automata)
run(sim, max_time)

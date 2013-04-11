using Base.Test
using SimJulia

type Player
	name::ASCIIString
	lives::Int64
	damage::Int64
	message::ASCIIString
	function Player(name::ASCIIString, lives::Int64)
		new(name, lives, 0, "Drat! Some $name survived the Federation attack")
	end
end

function killed(player::Player)
	return player.damage > 5
end

function life(romulans::Process, player::Player)
	while true
		waituntil(romulans, killed, player)
		player.damage = 0
		player.lives -= 1
		if player.lives == 0
			player.message = "$(player.name) wiped out by Federation at time $(now(romulans))"
			stop(simulation(romulans))
		end
	end
end

function fight(shooter::Process, target::Player)
	println("Three romulans attempting to escape!")
	while true
		if floor(rand()*10) < 2
			target.damage += 1
			if target.damage <= 5
				println("Ha! $(target.name) hit! Damage = $(target.damage)")
			else
				if target.lives - 1 == 0
					println("No more $(target.name) left!")
				else
					println("Now only $(target.lives - 1) $(target.name) left!")
				end
			end
		end
		hold(shooter, 1.0)
	end
end

sim = Simulation(uint(16))
game_over = 100.0
target = Player("Romulans", 3)
romulans = Process(sim, "Romulans")
activate(romulans, 0.0, life, target)
shooter = Process(sim, "Shooter")
activate(shooter, 0.0, fight, target)
run(sim, game_over)
println(target.message)
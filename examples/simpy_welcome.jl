using SimJulia

function clock(env::Environment, name::ASCIIString, tick::Float64)
  while true
    println("$name $(now(env))")
    yield(Timeout(env, tick))
  end
end

env = Environment()
Process(env, clock, "fast", 0.5)
Process(env, clock, "slow", 1.0)
run(env, 2.0)

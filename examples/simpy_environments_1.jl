using SimJulia

function my_proc(env::Environment)
  yield(timeout(env, 1.0))
  return "Monty Python's Flying Circus"
end

env = Environment()
proc = Process(env, my_proc)
println(run(env, proc))
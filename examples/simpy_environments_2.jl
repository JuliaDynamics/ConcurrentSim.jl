using SimJulia

function subfunc(env::Environment)
  println("Active process: $(active_process(env))")
end

function my_proc2(env::Environment)
  println("Active process: $(active_process(env))")
  yield(Timeout(env, 1.0))
  subfunc(env)
end

env = Environment()
Process(env, my_proc2)
println("Time: $(peek(env))")
try
  println(active_process(env))
catch exc
  println("No active process")
end
step(env)
println("Time: $(peek(env))")
try
  println(active_process(env))
catch exc
  println("No active process")
end
step(env)
println("Time: $(peek(env))")
step(env)
println("Time: $(peek(env))")

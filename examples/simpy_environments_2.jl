using SimJulia

function subfunc(env::Environment)
  println(active_process(env))
end

function my_proc(env::Environment)
  println(active_process(env))
  subfunc(env)
  yield(Timeout(env, 1.0))
end

env = Environment()
p1 = Process(env, my_proc)
try
  println(active_process(env))
catch exc
  println("None")
end
println("$(peek(env))")
step(env)
println("$(peek(env))")
try
  println(active_process(env))
catch exc
  println("None")
end
step(env)
println("$(peek(env))")
step(env)
println("$(peek(env))")

using SimJulia

function subfunc(env::Environment)
  println(active_process(env))
end

function my_proc(env::Environment)
  while true
    println(active_process(env))
    subfunc(env)
    yield(timeout(env, 1.0))
  end
end

env = Environment()
p1 = Process(env, my_proc)
try
  println(active_process(env))
catch exc
  println("None")
end
step(env)
println(active_process(env))
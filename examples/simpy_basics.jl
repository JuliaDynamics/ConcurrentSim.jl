using SimJulia

function example(env::Environment)
  value = yield(timeout(env, 1.0, 42))
  println("now=$(now(env)), value=$value")
end

env = Environment()
p = Process(env, example)
run(env )

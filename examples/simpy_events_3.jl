using SimJulia

function sub(env::Environment)
  yield(Timeout(env, 1.0))
  return 23
end

function parent(env::Environment)
  return ret = yield(Process(env, sub))
end

env = Environment()
ret = run(env, Process(env, parent))
println(ret)

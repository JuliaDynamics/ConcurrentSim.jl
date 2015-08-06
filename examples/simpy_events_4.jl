using SimJulia

function sub(env::Environment)
  yield(timeout(env, 1.0))
  return 23
end

function parent(env::Environment)
  start = now(env)
  sub_proc = yield(start_delayed(env, 3.0, sub))
  @assert(now(env) - start == 3.0)
  ret = yield(sub_proc)
end

env = Environment()
ret = run(env, Process(env, parent))
println(ret)

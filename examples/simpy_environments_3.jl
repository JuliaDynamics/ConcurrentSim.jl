using SimJulia

function my_proc3(env::Environment)
  yield(Timeout(env, 1.0))
  return 42
end

function other_proc(env::Environment)
  ret_val = yield(Process(env, my_proc3))
  @assert(ret_val == 42)
end

env = Environment()
Process(env, other_proc)
run(env)

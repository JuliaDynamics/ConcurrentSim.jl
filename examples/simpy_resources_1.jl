using SimJulia

function print_stats(res::Resource)
  println("$(count(res)) of $(capacity(res)) are allocated.")
  println("  Users: $(res.users)")
  println("  Queued processes: $(res.put_queue)")
end

function resource_user(env::Environment, res::Resource)
  print_stats(res)
  yield(Request(res))
  print_stats(res)
  yield(Release(res))
  print_stats(res)
end

env = Environment()
res = Resource(env, 1)
Process(env, resource_user, res)
Process(env, resource_user, res)
run(env)

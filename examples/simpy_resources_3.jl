using SimJulia

function resource_user(env::Environment, name::Int, res::Resource, wait::Float64, prio::Int)
  yield(timeout(env, wait))
  println("$name requesting at $(now(env)) with priority=$prio")
  yield(request(res, prio, true))
  println("$name got resource at $(now(env))")
  try
    yield(timeout(env, 3.0))
    yield(release(res))
  catch exc
    by = cause(exc)
    usage = now(env) - usage_since(exc)
    println("$name got preempted by $by at $(now(env)) after $usage")
  end
end

env = Environment()
res = Resource(env, 1)
p1 = Process(env, resource_user, 1, res, 0.0, 0)
p2 = Process(env, resource_user, 2, res, 1.0, 0)
p3 = Process(env, resource_user, 3, res, 2.0, -1)
run(env)

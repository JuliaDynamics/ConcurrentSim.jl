using SimJulia

function resource_user(env::Environment, name::Int, res::Resource, wait::Float64, prio::Int)
  yield(Timeout(env, wait))
  println("$name Requesting at $(now(env)) with priority=$prio")
  yield(Request(res, prio, true))
  println("$name got resource at $(now(env))")
  try
    yield(Timeout(env, 3.0))
    yield(Release(res))
  catch exc
    pre = cause(exc)
    usage = now(env) - usage_since(pre)
    println("$name got preempted by $(by(pre)) at $(now(env)) after $usage")
  end
end

env = Environment()
res = Resource(env, 1)
p1 = Process(env, resource_user, 1, res, 0.0, 0)
p2 = Process(env, resource_user, 2, res, 1.0, 0)
p3 = Process(env, resource_user, 3, res, 2.0, -1)
run(env)

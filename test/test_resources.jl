using SimJulia
using Base.Test

function generator(env::Environment, res::Resource)
  id = 0
  while true
    id += 1
    yield(Timeout(env, rand()))
    Process(env, handling, res, id)
  end
end

function handling(env::Environment, res::Resource, id::Int64)
  println("Number $id requests handling at time $(now(env))")
  yield(Request(res))
  println("Number $id starts handling at time $(now(env))")
  yield(Timeout(env, 1.5))
  println("Number $id stops handling at time $(now(env))")
  yield(Release(res))
  println("Number $id is released at time $(now(env))")
end

env = Environment()
res = Resource(env, false)
Process(env, generator, res)
run(env, 2.0)
env2 = Environment(2.0)
res2 = Resource(env2, 2)
Process(env2, generator, res2)
run(env2, 8.0)

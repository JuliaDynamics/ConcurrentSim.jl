using SimJulia
using Base.Test

function generator(env::Environment, res::Resource, preempt::Bool)
  id = 100
  while true
    id -= 1
    yield(Timeout(env, rand()))
    Process(env, handling, res, id, preempt)
  end
end

function handling(env::Environment, res::Resource, nr::Int64, preempt::Bool)
  duration = 2.25*rand()
  println("Number $nr Requests handling at time $(now(env))")
  token = yield(Request(res, nr, preempt))
  println("Number $nr starts handling at time $(now(env))")
  start_time = now(env)
  try
    yield(Timeout(env, duration))
  catch exc
    println(exc)
    println("Number $nr Request is preempted at time $(now(env))")
    while duration > 0.0
      duration -= now(env) - start_time
      println("Number $nr reRequests handling at time $(now(env))")
      yield(Request(res, token, nr, preempt))
      println("Number $nr restarts handling at time $(now(env))")
      try
        yield(Timeout(env, duration))
        duration = 0.0
      catch exc
        println(exc)
      end
    end
  end
  println("Number $nr stops handling at time $(now(env))")
  yield(Release(res))
  println("Number $nr is Released at time $(now(env))")
end

env = Environment()
res = Resource(env)
Process(env, generator, res, false)
run(env, 2.0)
env2 = Environment(2.0)
res2 = Resource(env2, 2)
Process(env2, generator, res2, true)
run(env2, 8.0)

using SimJulia
using Base.Test

function generator(env::Environment, res::Resource, preempt::Bool)
  id = 100
  while true
    id -= 1
    yield(timeout(env, rand()))
    Process(env, handling, res, id, preempt)
  end
end

function handling(env::Environment, res::Resource, nr::Int64, preempt::Bool)
  try
    println("Number $nr requests handling at time $(now(env))")
    yield(request(res, nr, preempt))
    println("Number $nr starts handling at time $(now(env))")
    yield(timeout(env, 2.25*rand()))
    println("Number $nr stops handling at time $(now(env))")
    yield(release(res))
    println("Number $nr is released at time $(now(env))")
  catch exc
    println("Number $nr request is preempted at time $(now(env)) by $(cause(exc)) having id $(id(exc)) in use since $(usage_since(exc))")
  end

end

env = Environment()
res = Resource(env)
Process(env, generator, res, false)
run(env, 2.0)
env2 = Environment(2.0)
res2 = Resource(env2, 2)
Process(env2, generator, res2, true)
run(env2, 8.0)

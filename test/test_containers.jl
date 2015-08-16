using SimJulia
using SimJulia.Containers

function putter(env::Environment, delay::Float64, cont::Container)
  yield(Timeout(env, delay))
  println("Putting start at $(now(env)), level=$(level(cont))")
  yield(Put(cont, 400))
  println("Putting stop at $(now(env)), level=$(level(cont))")
end

function getter(env::Environment, delay::Float64, cont::Container)
  yield(Timeout(env, delay))
  println("Getting start at $(now(env)), level=$(level(cont))")
  yield(Get(cont, 500))
  println("Getting stop at $(now(env)), level=$(level(cont))")
end

env = Environment()
cont = Container{Int}(env, 1000, 100)
for i = 1:4
  Process(env, putter, i*5.0, cont)
  Process(env, getter, i*30.0, cont)
end
Process(env, putter, 130.0, cont)
run(env)

using SimJulia

function putter(env::Environment, delay::Float64, cont::Container)
  yield(Timeout(env, delay))
  println("Putting start at $(now(env)), level=$(level(cont))")
  yield(Put(cont, 300))
  println("Putting stop at $(now(env)), level=$(level(cont))")
end

function getter(env::Environment, delay::Float64, cont::Container)
  yield(Timeout(env, delay))
  println("Getting start at $(now(env)), level=$(level(cont))")
  get = Get(cont, 500)
  result = yield(get | Timeout(env, 10.0))
  if in(get, keys(result))
    println("Getting stop at $(now(env)), level=$(level(cont))")
  else
    cancel(get)
    println("Waited too long")
  end
end

env = Environment()
cont = Container{Int}(env, 1000, 100)
for i = 1:8
  Process(env, putter, i*5.0, cont)
  Process(env, getter, i*30.0, cont)
end
Process(env, putter, 130.0, cont)
run(env)

using SimJulia

function producer(env::Environment, sto::Store)
  for i = 1:100
    yield(Timeout(env, 2.0))
    yield(Put(sto, "spam $i"))
    println("Produced spam at $(now(env))")
  end
end

function consumer(env::Environment, name::Int, sto::Store)
  while true
    yield(Timeout(env, 1.0))
    println("$name requesting spam at $(now(env))")
    item = yield(Get(sto))
    println("$name got $item at $(now(env))")
  end
end

env = Environment()
sto = Store{ASCIIString}(env, 2)

prod = Process(env, producer, sto)
consumers = [Process(env, consumer, i, sto) for i=1:2]

run(env, 5.0)

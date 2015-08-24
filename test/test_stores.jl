using SimJulia

function sender(env::Environment, sto::Store)
  i = 0
  while true
    yield(Timeout(env, rand()*5))
    yield(Put(sto, "Msg $(i+=1)"))
    println(items(sto))
  end
end

function receiver(env::Environment, sto::Store)
  while true
    yield(Timeout(env, rand()*5))
    msg = yield(Get(sto))
    println("Received $msg at $(now(env))")
  end
end

env = Environment()
sto = Store{ASCIIString}(env, 4)
Process(env, sender, sto)
Process(env, receiver, sto)
run(env, 100.0)

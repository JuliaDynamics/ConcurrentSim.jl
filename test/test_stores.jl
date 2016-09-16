using SimJulia

type StoreObject
  i :: Int
end

function consumer(sim::Simulation, sto::Store)
  for i = 1:10
    yield(sim, timeout(sim, rand()))
    println("$(now(sim)), consumer is demanding object")
    obj = yield(sim, get(sim, sto))
    println("$(now(sim)), consumer is being served with object $(obj.i)")
  end
end

function producer(sim::Simulation, sto::Store)
  for i = 1:10
    println("$(now(sim)), producer is offering object $i")
    yield(sim, put(sim, sto, StoreObject(i)))
    println("$(now(sim)), producer is being served")
    yield(sim, timeout(sim, 2*rand()))
  end
end

sim = Simulation()
sto = Store(StoreObject)
Process(sim, consumer, sto)
Process(sim, producer, sto)
run(sim)

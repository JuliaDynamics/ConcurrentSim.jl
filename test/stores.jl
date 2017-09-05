using SimJulia
using ResumableFunctions

struct StoreObject
  i :: Int
end

@resumable function my_consumer(sim::Simulation, sto::Store)
  for j in 1:10
    @yield Timeout(sim, rand())
    println("$(now(sim)), consumer is demanding object")
    obj = @yield Get(sto)
    println("$(now(sim)), consumer is being served with object ", obj.i)
  end
end

@resumable function my_producer(sim::Simulation, sto::Store)
  for j in 1:10
    println("$(now(sim)), producer is offering object $j")
    @yield Put(sto, StoreObject(j))
    println("$(now(sim)), producer is being served")
    @yield Timeout(sim, 2*rand())
  end
end

sim = Simulation()
sto = Store(StoreObject, sim)
@coroutine my_consumer(sim, sto)
@coroutine my_producer(sim, sto)
run(sim)

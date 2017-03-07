using SimJulia

struct StoreObject
  i :: Int
end

@stateful function my_consumer(sim::Simulation, sto::Store)
  i = 1
  while true
    @yield return Timeout(sim, rand())
    println("$(now(sim)), consumer is demanding object")
    obj = @yield return Get(sto)
    println("$(now(sim)), consumer is being served with object $(obj.i)")
    i == 10 && break
    i += 1
  end
end

@stateful function my_producer(sim::Simulation, sto::Store)
  i = 1
  while true
    println("$(now(sim)), producer is offering object $i")
    @yield return Put(sto, StoreObject(i))
    println("$(now(sim)), producer is being served")
    @yield return Timeout(sim, 2*rand())
    i == 10 && break
    i += 1
  end
end

sim = Simulation()
sto = Store(StoreObject, sim)
@Coroutine my_consumer(sim, sto)
@Coroutine my_producer(sim, sto)
run(sim)

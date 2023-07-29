using ConcurrentSim
using ResumableFunctions

struct StoreObject
  i :: Int
end

@resumable function my_consumer(sim::Simulation, sto::Store)
  for j in 1:10
    @yield timeout(sim, rand())
    println("$(now(sim)), consumer is demanding object")
    obj = @yield get(sto)
    println("$(now(sim)), consumer is being served with object ", obj.i)
  end
end

@resumable function my_producer(sim::Simulation, sto::Store)
  for j in 1:10
    println("$(now(sim)), producer is offering object $j")
    @yield put!(sto, StoreObject(j))
    println("$(now(sim)), producer is being served")
    @yield timeout(sim, 2*rand())
  end
end

sim = Simulation()
sto = Store{StoreObject}(sim)
@process my_consumer(sim, sto)
@process my_producer(sim, sto)
run(sim)

##

@test_throws ErrorException unlock(sto)
@test_throws ErrorException lock(sto)

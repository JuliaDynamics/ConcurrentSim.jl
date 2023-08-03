using ConcurrentSim
using ResumableFunctions
using Test
using DataFrames, Tables

struct StoreObject
  i :: Int
end

@resumable function my_consumer(sim::Simulation, sto)
  for j in 1:10
    @yield timeout(sim, rand())
    println("$(now(sim)), consumer is demanding object")
    obj = @yield take!(sto)
    println("$(now(sim)), consumer is being served with object ", obj.i)
  end
end

@resumable function my_producer(sim::Simulation, sto)
  for j in 1:10
    println("$(now(sim)), producer is offering object $j")
    @yield put!(sto, StoreObject(j))
    println("$(now(sim)), producer is being served")
    @yield timeout(sim, 2*rand())
  end
end

sim = Simulation()
sto = TrackedResource(Store{StoreObject}(sim))
@process my_consumer(sim, sto)
@process my_producer(sim, sto)
run(sim)

df = DataFrame(sto)
@test df[!,:events] == Tables.getcolumn(sto, 1)
@test df[!,:times] == Tables.getcolumn(sto, 2)

@test_throws ErrorException Tables.getcolumn(sto, 3)
@test_throws ErrorException Tables.getcolumn(sto, :lala)

@test Tables.columnaccess(typeof(sto))
Tables.schema(sto)

using ConcurrentSim

## Containers with Float64 priority
sim = Simulation()
con = Container{Float64}(sim,0)
put!(con, 1; priority = 10)
put!(con, 1; priority = 9.1)
put!(con, 1; priority = UInt(9))
put!(con, 1; priority = BigInt(8))
put!(con, 1; priority = BigFloat(7.1))
put!(con, 1; priority = 7)
put!(con, 1; priority = 6.1)
put!(con, 1; priority = BigInt(5))
put!(con, 1; priority = BigFloat(-Inf))
@show keys(con.put_queue)

## Containers with Int64 priority
sim = Simulation()
con = Container{Int}(sim,0)
put!(con, 1; priority = 10)
put!(con, 1; priority = 9.0)
put!(con, 1; priority = UInt(9))
put!(con, 1; priority = BigInt(8))
put!(con, 1; priority = BigFloat(7.0))
put!(con, 1; priority = 7)
put!(con, 1; priority = 6.0)
put!(con, 1; priority = BigInt(5))
put!(con, 1; priority = typemin(Int))
@show keys(con.put_queue)

## Stores with Float64 priority
sim = Simulation()
sto = Store{Symbol,Float64}(sim; capacity = UInt(5))
put!(sto, :a; priority = 10)
put!(sto, :a; priority = 9.1)
put!(sto, :a; priority = UInt(9))
put!(sto, :a; priority = BigInt(8))
put!(sto, :a; priority = BigFloat(7.1))
put!(sto, :b; priority = 7)
put!(sto, :b; priority = 6.1)
put!(sto, :b; priority = BigInt(5))
put!(sto, :b; priority = BigFloat(-Inf))
@show sto.items
@show keys(sto.put_queue)

## Stores with Int64 priority
sim = Simulation()
sto = Store{Symbol,Int}(sim; capacity = UInt(5))
put!(sto, :a; priority = 10)
put!(sto, :a; priority = 9.0)
put!(sto, :a; priority = UInt(9))
put!(sto, :a; priority = BigInt(8))
put!(sto, :a; priority = BigFloat(7.0))
put!(sto, :b; priority = 7)
put!(sto, :b; priority = 6.0)
put!(sto, :b; priority = BigInt(5))
put!(sto, :b; priority = typemin(UInt))
@show sto.items
@show keys(sto.put_queue)
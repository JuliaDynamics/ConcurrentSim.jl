using SimJulia

function client(sim::Simulation, res::Resource, i::Int, priority::Int)
  println("$(now(sim)), client $i is waiting")
  yield(sim, request(sim, res, priority=priority))
  println("$(now(sim)), client $i is being served")
  yield(sim, timeout(sim, rand()))
  println("$(now(sim)), client $i has been served")
  yield(sim, release(sim, res))
end

function generate(sim::Simulation, res::Resource)
  for i = 1:10
    Process(sim, client, res, i, 10-i)
    yield(sim, timeout(sim, 0.5*rand()))
  end
end

sim = Simulation()
res = Resource(2, level=1)
Process(sim, generate, res)
run(sim)

function consumer(sim::Simulation, con::Container)
  for i = 1:10
    amount = 3*rand()
    println("$(now(sim)), consumer is demanding $amount")
    yield(sim, timeout(sim, rand()))
    yield(sim, get(sim, con, amount))
    println("$(now(sim)), consumer is being served, level is $(con.level)")
    yield(sim, timeout(sim, 5*rand()))
  end
end

function producer(sim::Simulation, con::Container)
  for i = 1:10
    amount = 2*rand()
    println("$(now(sim)), producer is offering $amount")
    yield(sim, timeout(sim, rand()))
    yield(sim, put(sim, con, amount))
    println("$(now(sim)), producer is being served, level is $(con.level)")
    yield(sim, timeout(sim, 5*rand()))
  end
end

sim = Simulation()
con = Container(10.0, level=5.0)
Process(sim, consumer, con)
Process(sim, producer, con)
run(sim)

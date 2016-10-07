using SimJulia

function client(sim::Simulation, res::Resource, i::Int, priority::Int)
  println("$(now(sim)), client $i is waiting")
  yield(request(res, priority=priority))
  println("$(now(sim)), client $i is being served")
  yield(timeout(sim, rand()))
  println("$(now(sim)), client $i has been served")
  yield(release(res))
end

function generate(sim::Simulation, res::Resource)
  for i = 1:10
    Process(client, sim, res, i, 10-i)
    yield(timeout(sim, 0.5*rand()))
  end
end

sim = Simulation()
res = Resource(sim, 2, level=1)
Process(generate, sim, res)
run(sim)

function consumer(sim::Simulation, con::Container)
  for i = 1:10
    amount = 3*rand()
    println("$(now(sim)), consumer is demanding $amount")
    yield(timeout(sim, 1.0*rand()))
    yield(get(con, amount))
    println("$(now(sim)), consumer is being served, level is $(con.level)")
    yield(timeout(sim, 5.0*rand()))
  end
end

function producer(sim::Simulation, con::Container)
  for i = 1:10
    amount = 2*rand()
    println("$(now(sim)), producer is offering $amount")
    yield(timeout(sim, 1.0*rand()))
    yield(put(con, amount))
    println("$(now(sim)), producer is being served, level is $(con.level)")
    yield(timeout(sim, 3.0*rand()))
  end
end

sim = Simulation()
con = Container(sim, 10.0, level=5.0)
Process(consumer, sim, con)
Process(producer, sim, con)
run(sim)

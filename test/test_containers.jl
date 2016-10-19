using SimJulia

function client(sim::Simulation, res::Resource, i::Int, priority::Int)
  println("$(now(sim)), client $i is waiting")
  yield(Request(res, priority=priority))
  println("$(now(sim)), client $i is being served")
  yield(Timeout(sim, rand()))
  println("$(now(sim)), client $i has been served")
  yield(Release(res))
end

function generate(sim::Simulation, res::Resource)
  for i = 1:10
    Process(client, sim, res, i, 10-i)
    yield(Timeout(sim, 0.5*rand()))
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
    yield(Timeout(sim, 1.0*rand()))
    get_ev = Get(con, amount)
    val = yield(get_ev | Timeout(sim, rand()))
    if val[get_ev].state == SimJulia.triggered
      println("$(now(sim)), consumer is being served, level is $(con.level)")
      yield(Timeout(sim, 5.0*rand()))
    else
      println("$(now(sim)), consumer has timed out")
      cancel(con, get_ev)
    end
  end
end

function producer(sim::Simulation, con::Container)
  for i = 1:10
    amount = 2*rand()
    println("$(now(sim)), producer is offering $amount")
    yield(Timeout(sim, 1.0*rand()))
    yield(Put(con, amount))
    println("$(now(sim)), producer is being served, level is $(con.level)")
    yield(Timeout(sim, 5.0*rand()))
  end
end

sim = Simulation()
con = Container(sim, 10.0, level=5.0)
Process(consumer, sim, con)
Process(producer, sim, con)
run(sim)

function resource_user(sim::Simulation, res::Resource, i::Int)
  Request(res) do req
    println("Requested $i")
    val = yield(req | Timeout(sim, rand()))
    if val[req].state == SimJulia.triggered
      println("Received $i")
      yield(Timeout(sim, rand()))
    else
      println("Timeout $i")
    end
  end
  println("Released automatically $i")
end

function create_users(sim::Simulation)
  res = Resource(sim)
  for i = 1:10
    Process(resource_user, sim, res, i)
    yield(Timeout(sim, rand()))
  end
  capacity(res)
end

sim = Simulation()
Process(create_users, sim)
run(sim)

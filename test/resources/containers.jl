using SimJulia

@resumable function client(sim::Simulation, res::Resource, i::Int, priority::Int)
  println("$(now(sim)), client $i is waiting")
  @yield request(res, priority=priority)
  println("$(now(sim)), client $i is being served")
  @yield timeout(sim, rand())
  println("$(now(sim)), client $i has been served")
  @yield release(res)
end

@resumable function generate(sim::Simulation, res::Resource)
  for i in 1:10
    @process client(sim, res, i, 10-i)
    @yield timeout(sim, 0.5*rand())
  end
end

sim = Simulation()
res = Resource(sim, 2; level=1)
println(res)
@process generate(sim, res)
run(sim)

@resumable function my_consumer(sim::Simulation, con::Container)
  for i in 1:10
    amount = 3*rand()
    println("$(now(sim)), consumer is demanding $amount")
    @yield timeout(sim, 1.0*rand())
    get_ev = get(con, amount)
    val = @yield get_ev | timeout(sim, rand())
    if val[get_ev].state == SimJulia.processed
      println("$(now(sim)), consumer is being served, level is ", con.level)
      @yield timeout(sim, 5.0*rand())
    else
      println("$(now(sim)), consumer has timed out")
      cancel(con, get_ev)
    end
  end
end

@resumable function my_producer(sim::Simulation, con::Container)
  for i in 1:10
    amount = 2*rand()
    println("$(now(sim)), producer is offering $amount")
    @yield timeout(sim, 1.0*rand())
    @yield put(con, amount)
    level = con.level
    println("$(now(sim)), producer is being served, level is ", level)
    @yield timeout(sim, 5.0*rand())
  end
end

sim = Simulation()
con = Container(sim, 10.0; level=5.0)
@process my_consumer(sim, con)
@process my_producer(sim, con)
run(sim)

using SimJulia

@resumable function client(sim::Simulation, res::Resource, i::Int, priority::Int)
  println("$(now(sim)), client $i is waiting")
  @yield return Request(res, priority=priority)
  println("$(now(sim)), client $i is being served")
  @yield return Timeout(sim, rand())
  println("$(now(sim)), client $i has been served")
  @yield return Release(res)
end

@resumable function generate(sim::Simulation, res::Resource)
  i = 1
  while true
    @coroutine client(sim, res, i, 10-i)
    @yield return Timeout(sim, 0.5*rand())
    i == 10 && break
    i += 1
  end
end

sim = Simulation()
res = Resource(sim, 2; level=1)
@coroutine generate(sim, res)
run(sim)

@resumable function my_consumer(sim::Simulation, con::Container)
  i = 1
  while true
    amount = 3*rand()
    println("$(now(sim)), consumer is demanding $amount")
    @yield return Timeout(sim, 1.0*rand())
    get_ev = Get(con, amount)
    val = @yield return get_ev | Timeout(sim, rand())
    if val[get_ev].state == SimJulia.triggered
      level = con.level
      println("$(now(sim)), consumer is being served, level is $level")
      @yield return Timeout(sim, 5.0*rand())
    else
      println("$(now(sim)), consumer has timed out")
      cancel(con, get_ev)
    end
    i == 10 && break
    i += 1
  end
end

@resumable function my_producer(sim::Simulation, con::Container)
  i = 1
  while true
    amount = 2*rand()
    println("$(now(sim)), producer is offering $amount")
    @yield return Timeout(sim, 1.0*rand())
    @yield return Put(con, amount)
    level = con.level
    println("$(now(sim)), producer is being served, level is $level")
    @yield return Timeout(sim, 5.0*rand())
    i == 10 && break
    i += 1
  end
end

sim = Simulation()
con = Container(sim, 10.0; level=5.0)
@coroutine my_consumer(sim, con)
@coroutine my_producer(sim, con)
run(sim)

 

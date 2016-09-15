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
res = Resource()
Process(sim, generate, res)
run(sim)

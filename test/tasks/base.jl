using SimJulia

function fibonnaci(sim::Simulation)
  a = 0.0
  b = 1.0
  for i = 1:10
    println("Fibonnaci value equals ", a, " at time ", now(sim))
    yield(Timeout(sim, 1.0))
    a, b = b, a+b
  end
  a
end

function wait_for_process(sim::Simulation, process::Process)
  val = yield(process)
  println("Fibonnaci ended with ", val, " at time ", now(sim))
end

sim = Simulation()
fib = @process fibonnaci(sim)
wait = @process wait_for_process(sim, fib)
run(sim)

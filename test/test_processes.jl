using SimJulia
using Base.Test

function fib(env::Environment, a=1, b=1)
  while a < 10
    println("At time $(now(env)) the value of $(active_process(env)) is $b")
    try
      yield(env, Timeout(env, 3.0))
    catch exc
      if isa(exc, InterruptException)
        println("At time $(now(env)) an interrupt occured")
        return
      end
    end
    tmp = a+b
    a = b
    b = tmp
  end
end

function interrupt_fib(env::Environment, proc::Process, when::Float64)
  while true
    yield(env, Timeout(env, when))
    interrupt(env, proc)
  end
end

function wait_fib(env::Environment, proc::Process)
  println("Start waiting at $(now(env))")
  yield(env, proc)
  println("Stop waiting at $(now(env))")
end

env = Environment()
proc = Process(env, "Fibonnaci", fib)
proc2 = Process(env, "Fibonnaci2", fib, 2, 3)
proc_interrupt = Process(env, "Interrupt Fibonnaci", interrupt_fib, proc, 4.0)
proc_wait = Process(env, "Wait Fibonnaci", wait_fib, proc)
run(env, 20.0)
println("End of simulation at time $(now(env))")

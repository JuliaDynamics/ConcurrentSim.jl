using SimJulia
using Base.Test

function fib(env::Environment, a=1, b=1)
  while a < 10
    println("At time $(env.now) the value of $(env.active_proc.name) is $b")
    try
      yield(env, timeout(env, 3.0))
    catch exc
      if isa(exc, InterruptException)
        println("At time $(env.now) an interrupt occured")
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
    yield(env, timeout(env, when))
    interrupt(env, proc)
  end
end

env = Environment()
proc = process(env, "Fibonnaci", fib)
proc2 = process(env, "Fibonnaci2", fib, 2, 3)
proc_interrupt = process(env, "Interrupt Fibonnaci", interrupt_fib, proc, 4.0)
run(env, 20.0)
println("End of simulation at time $(env.now)")

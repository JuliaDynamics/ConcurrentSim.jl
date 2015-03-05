using SimJulia
using Base.Test

function fib(env::Environment, a=1, b=1)
  while a < 10
    println("At time $(now(env)) the value of $(active_process(env)) is $b")
    try
      yield(Timeout(env, 3.0))
    catch exc
      if isa(exc, Interrupt)
        println("At time $(now(env)) an interrupt occured")
        println(exc)
        println(cause(exc))
        return "An interrupt occured"
      end
    end
    tmp = a+b
    a = b
    b = tmp
  end
end

function interrupt_fib(env::Environment, proc::Process, when::Float64, ev::Event)
  while true
    yield(Timeout(env, when))
    interrupt(proc)
    yield(Timeout(env, when))
    fail(ev, ErrorException("Failed event"))
  end
end

function wait_fib(env::Environment, proc::Process, ev::Event)
  println("Start waiting at $(now(env))")
  value = yield(proc)
  println("Value is $value")
  println("Stop waiting at $(now(env))")
  try
    yield(ev)
  catch exc
    println(exc)
  end
  yield(ev)
end

env = Environment()
ev = Event(env)
proc = Process(env, "Fibonnaci", fib)
proc2 = Process(env, "Fibonnaci2", fib, 2, 3)
proc_interrupt = Process(env, "Interrupt Fibonnaci", interrupt_fib, proc, 4.0, ev)
proc_wait = Process(env, "Wait Fibonnaci", wait_fib, proc, ev)
try
  run(env, 20.0)
catch exc
  println(exc)
end
println("End of simulation at time $(now(env))")

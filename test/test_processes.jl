using SimJulia
using Base.Test

function fib(env::BaseEnvironment, a=1, b=1)
  while a < 10
    println("At time $(now(env)) the value is $b")
    try
      yield(Timeout(env, 3.0))
    catch exc
      if isa(exc, SimJulia.InterruptException)
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

function interrupt_fib(env::BaseEnvironment, proc::Process, when::Float64, ev::Event)
  while true
    yield(Timeout(env, when))
    println("Before interrupt")
    yield(Interrupt(env, proc))
    #interrupt(env, proc)
    println("After interrupt")
    yield(Timeout(env, when))
    fail(ev, ErrorException("Failed event"))
    try
      yield(ev)
    catch exc
      println(exc)
    end
  end
end

function wait_fib(env::BaseEnvironment, proc::Process, ev::Event)
  println("Start waiting at $(now(env))")
  value = yield(proc)
  println("Value is $value")
  println("Stop waiting at $(now(env))")
  try
    yield(ev)
  catch exc
    println(exc)
  end
end

function ev_too_late(env::BaseEnvironment, ev::Event, when::Float64)
  yield(Timeout(env, when))
  println("Processed: $(processed(ev))")
  try
    value = yield(ev)
  catch exc
    println(exc)
    rethrow(exc)
  end
end

function die(env::BaseEnvironment, proc::Process)
  try
    println("I wait for a died process")
    value = yield(proc)
  catch exc
    println("I received a died process")
    rethrow(exc)
  end
end

env = Environment()
ev = Event(env)
proc = Process(env, fib)
proc2 = Process(env, fib, 2, 3)
proc_interrupt = Process(env, interrupt_fib, proc, 4.0, ev)
proc_wait = Process(env, wait_fib, proc, ev)
proc_too_late = Process(env, ev_too_late, ev, 16.0)
proc_die = Process(env, die, proc_too_late)
try
  run(env, 20.0)
catch exc
  println(exc)
end
println("End of simulation at time $(now(env))")

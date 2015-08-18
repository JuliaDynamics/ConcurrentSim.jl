using SimJulia

function fib(env::Environment, a=1, b=1)
  while a < 10
    println("At time $(now(env)) the value is $b")
    try
      yield(Timeout(env, 3.0))
    catch exc
      println("At time $(now(env)) an Interrupt occured")
      println(exc)
      println(cause(exc))
      return "An Interrupt occured"
    end
    tmp = a+b
    a = b
    b = tmp
  end
end

function Interrupt_fib(env::Environment, proc::Process, when::Float64, ev::Event)
  while true
    yield(Timeout(env, when))
    println("Before Interrupt")
    yield(Interruption(proc, "My Interrupt"))
    println("After Interrupt")
    yield(Timeout(env, when))
    fail(ev, ErrorException("Failed event"))
    try
      value = yield(ev)
    catch exc
      println("Exception: $exc")
    end
    yield(Timeout(env, when))
    try
       value = yield(ev)
       println("Value: $value")
    catch exc
       println("Exception: $exc")
    end
  end
end

function wait_fib(env::Environment, proc::Process, ev::Event)
  println("Start waiting at $(now(env))")
  println("Is process done? $(is_process_done(proc))")
  value = yield(proc)
  println("Value is $value")
  println("Stop waiting at $(now(env))")
  try
    yield(ev)
  catch exc
    println(exc)
  end
end

function ev_too_late(env::Environment, ev::Event, when::Float64)
  yield(Timeout(env, when))
  println("Processed: $(processed(ev))")
  throw(ErrorException("... too late"))
end

function callback_too_late(ev::Process)
  println("Too late ...")
end

function die(env::Environment, proc::Process)
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
proc_Interrupt = Process(env, Interrupt_fib, proc, 4.0, ev)
proc_wait = Process(env, wait_fib, proc, ev)
proc_too_late = Process(env, ev_too_late, ev, 16.0)
append_callback(proc_too_late, callback_too_late)
proc_die = Process(env, die, proc_too_late)
try
  run(env, 20.0)
catch exc
  println(exc)
end
println("End of simulation at time $(now(env))")

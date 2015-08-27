using SimJulia

function evaluate(events...)
  return true
end

function test_conditions(env::Environment, ev::Event, p :: Process)
  ev1 = Timeout(env, 2.0)
  ev2 = Timeout(env, 3.0)
  ev3 = Timeout(env, 2.5)
  println("Time is $(now(env))")
  println(keys(yield(ev1 & ev2 | ev3)))
  println("Time is $(now(env))")
  println(keys(yield(AnyOf(ev1, ev3))))
  println("Time is $(now(env))")
  println(keys(yield(AllOf(ev1, ev2, ev3))))
  println("Time is $(now(env))")
  try
    yield(AllOf(ev2, ev))
  catch exc
    println(exc)
  end
  println("Time is $(now(env))")
  println(keys(yield(p & ev1)))
  println("Time is $(now(env))")
end

function failure_ev(env::Environment, ev::Event)
  yield(Timeout(env, 4.0))
  fail(ev, ErrorException("Failure"))
end

function proc_cond(env::Environment)
  yield(Timeout(env, 5.0))
  return "Hello World!"
end

env = Environment()
oper = EventOperator(evaluate, Timeout(env, 1.0))
ev = Event(env)
p = Process(env, proc_cond)
Process(env, test_conditions, ev, p)
Process(env, failure_ev, ev)
run(env, 20.0)

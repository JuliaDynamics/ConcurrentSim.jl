using SimJulia

function evaluate(events::Vector{BaseEvent})
  return true
end

function test_conditions(env::Environment, ev::Event, p :: Process)
  ev1 = timeout(env, 2.0)
  ev2 = timeout(env, 3.0)
  ev3 = timeout(env, 2.5)
  println("Time is $(now(env))")
  println(keys(yield(ev1 & ev2 | ev3)))
  println("Time is $(now(env))")
  println(keys(yield(any_of(env, BaseEvent[ev1]))))
  println("Time is $(now(env))")
  println(keys(yield(all_of(env, BaseEvent[ev1, ev2, ev3]))))
  println("Time is $(now(env))")
  println(keys(yield(any_of(env, BaseEvent[]))))
  println("Time is $(now(env))")
  try
    yield(all_of(env, BaseEvent[ev2, ev]))
  catch exc
    println(exc)
  end
  println("Time is $(now(env))")
  println(keys(yield(p & ev1)))
  println("Time is $(now(env))")
end

function failure_ev(env::Environment, ev::Event)
  yield(timeout(env, 4.0))
  fail(ev, ErrorException("Failure"))
end

function proc_cond(env::Environment)
  yield(timeout(env, 5.0))
  return "Hello World!"
end

env = Environment()
events = BaseEvent[timeout(env, 1.0)]
cond = condition(env, evaluate, events)
ev = Event(env)
p = Process(env, proc_cond)
Process(env, test_conditions, ev, p)
Process(env, failure_ev, ev)
run(env, 20.0)

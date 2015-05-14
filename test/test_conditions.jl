using SimJulia

function evaluate(events::Vector{BaseEvent})
  return true
end

function test_conditions(env::Environment)
  ev1 = Timeout(env, 2.0)
  ev2 = Timeout(env, 3.0)
  ev3 = Timeout(env, 2.5)
  println("Time is $(now(env))")
  yield(ev1 & ev2 | ev3)
  println("Time is $(now(env))")
end

env = Environment()
events = BaseEvent[Timeout(env, 1.0)]
cond = SimJulia.Condition(env, evaluate, events)
Process(env, test_conditions)
run(env, 20.0)

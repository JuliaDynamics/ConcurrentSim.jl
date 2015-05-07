using SimJulia

function evaluate(events::Vector{Event})
  return true
end

function test_conditions(env::Environment)
  ev1 = Timeout(env, 2.0)
  ev2 = Timeout(env, 3.0)
  println("Time is $(now(env))")
  yield(env, and(env, ev1, ev2))
  println("Time is $(now(env))")
end

env = Environment()
events = [Timeout(env, 1.0)]
cond = SimJulia.Condition(env, evaluate, events)
Process(env, test_conditions)
run(env, 20.0)

using SimJulia

function test_condition(env::Environment)
  t1, t2 = timeout(env, 1.0, "spam"), timeout(env, 2.0, "eggs")
  ret = yield(t1 | t2)
  @assert(ret == [t1=>"spam"])
  # v4 @assert(ret == Dict(t1=>"spam"))
  t1, t2 = timeout(env, 1.0, "spam"), timeout(env, 2.0, "eggs")
  ret = yield(t1 & t2)
  @assert(ret == [t1=>"spam", t2=>"eggs"])
  # v4 @assert(ret == Dict(t1=>"spam", t2=>"eggs"))
  e1, e2, e3 = timeout(env, 1.0, "spam"), timeout(env, 2.0, "eggs"), timeout(env, 3.0, "eggs")
  yield((e1 | e2) & e3)
  @assert(all(map((ev)->processed(ev), [e1, e2, e3])))
end

env = Environment()
Process(env, test_condition)
run(env)

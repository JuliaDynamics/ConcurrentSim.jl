using SimJulia

function fetch_values_of_multiple_events(env::Environment)
  t1, t2 = timeout(env, 1.0, "spam"), timeout(env, 2.0, "eggs")
  ret = yield(t1 & t2)
  @assert(ret == [t1=>"spam", t2=>"eggs"])
  # v4 @assert(ret == Dict(t1=>"spam", t2=>"eggs")
end

env = Environment()
Process(env, fetch_values_of_multiple_events)
run(env)
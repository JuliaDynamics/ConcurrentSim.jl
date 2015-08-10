using SimJulia
using Compat

function fetch_values_of_multiple_events(env::Environment)
  t1, t2 = Timeout(env, 1.0, "spam"), Timeout(env, 2.0, "eggs")
  ret = yield(t1 & t2)
  @assert(ret == @compat Dict(t1=>"spam", t2=>"eggs"))
end

env = Environment()
Process(env, fetch_values_of_multiple_events)
run(env)

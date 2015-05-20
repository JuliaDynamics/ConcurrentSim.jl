using SimJulia
using Base.Test
function my_callback(ev::Event, succeed_ev::Event)
  println("Callback of $(ev)")
  println("Succeed is triggered: $(triggered(succeed_ev))")
  println("Succeed is processed: $(processed(succeed_ev))")
  succeed(succeed_ev, "Yes we can")
end

function my_callback2(ev::Event, fail_ev::Event)
  println("Callback of $(ev)")
  fail(fail_ev, ErrorException("No we can't"))
end

function succeed_callback(ev::Event)
  println("Succeed is triggered: $(triggered(ev))")
  println("Succeed is processed: $(processed(ev))")
  println(value(ev))
end

function fail_callback(ev::Event)
  println(value(ev))
end

env = Environment()
ev = timeout(env, 1.0)
ev2 = timeout(env, 2.0)
succeed_ev = Event(env)
fail_ev = Event(env)
append_callback(ev, my_callback, succeed_ev)
append_callback(ev2, my_callback2, fail_ev)
append_callback(succeed_ev, succeed_callback)
append_callback(fail_ev, fail_callback)
run(env)
println("Succeed is triggered: $(triggered(succeed_ev))")
println("Succeed is processed: $(processed(succeed_ev))")
println("End of simulation at time $(now(env))")

env = Environment(10.0)
run(env, 12.0)
println("End of simulation at time $(now(env))")

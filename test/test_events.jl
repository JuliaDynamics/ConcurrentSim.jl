using SimJulia
using Base.Test
function my_callback(env::Environment, ev::Event, succeed_ev::Event)
  println("Callback of $(ev) at $(now(env))")
  println("Succeed is triggered: $(triggered(succeed_ev))")
  println("Succeed is processed: $(processed(succeed_ev))")
  succeed(env, succeed_ev, "Yes we can")
end

function my_callback2(env::Environment, ev::Event, fail_ev::Event)
  println("Callback of $(ev) at $(now(env))")
  fail(env, fail_ev, ErrorException("No we can't"))
end

function succeed_callback(env::Environment, ev::Event)
  println("Succeed is triggered: $(triggered(ev))")
  println("Succeed is processed: $(processed(ev))")
  println(value(ev))
end

function fail_callback(env::Environment, ev::Event)
  println(value(ev))
end

env = Environment()
ev = Timeout(env, 1.0)
ev2 = Timeout(env, 2.0)
succeed_ev = Event()
fail_ev = Event()
append_callback(env, ev, my_callback, succeed_ev)
append_callback(env, ev2, my_callback2, fail_ev)
append_callback(env, succeed_ev, succeed_callback)
append_callback(env, fail_ev, fail_callback)
run(env)
println("Succeed is triggered: $(triggered(succeed_ev))")
println("Succeed is processed: $(processed(succeed_ev))")
println("End of simulation at time $(now(env))")

env = Environment(10.0)
run(env, 12.0)
println("End of simulation at time $(now(env))")

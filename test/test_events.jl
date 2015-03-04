using SimJulia
using Base.Test
function my_callback(env::Environment, ev::Event)
  println("Callback event $(ev.ev_id.id) at $(env.now) with value $(ev.value)")
end

env = Environment()
ev = timeout(env, 1.0)
println("Event is triggered: $(triggered(ev))")
push!(ev.callbacks, my_callback)
run(env)
println("End of simulation at time $(env.now)")

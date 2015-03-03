using SimJulia
using Base.Test
function my_callback(env::Environment, ev::Event)
  println("Callback event $(ev.id) at $(env.now) with value $(ev.value)")
end

env = Environment()
ev = timeout(env, 1.0)
push!(ev.callbacks, my_callback)
run(env, 2.0)
println("End of simulation at time $(env.now)")

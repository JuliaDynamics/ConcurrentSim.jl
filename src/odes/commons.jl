function init(env::Environment, cont::Continuous, integrator::QSS, model::Function, x₀::Vector{Float64})
  n = length(x₀)
  t = now(env)
  f, deps = model()
  zero_taylor = 0*Taylor1(Float64, integrator.order+1)
  for (i, q₀) in enumerate(x₀)
    push!(integrator.t, t)
    push!(integrator.q, q₀ + zero_taylor)
  end
  t₀ = t + Taylor1(Float64, integrator.order+1)
  x_vec = Vector{Taylor1}()
  for (i, q₀) in enumerate(x₀)
    push!(x_vec, integrate(f[i](t₀, integrator.q, cont.p), q₀))
  end
  for i in 1:integrator.order-1
    for (j, x) in enumerate(x_vec)
      integrator.q[j] = copy(x)
    end
    for (j, q₀) in enumerate(x₀)
      x_vec[j] = integrate(f[j](t₀, integrator.q, cont.p), q₀)
    end
  end
  for (i, x) in enumerate(x_vec)
    var = Variable(env, i, f, x)
    push!(cont.vars, var)
    @callback step(var, cont, integrator)
    schedule(var)
  end
end

function step(var::Variable, cont::Continuous, integrator::QSS)
  i = var.id
  env = environment(var)
  t = now(env)
  x₀ = advance_time(var, t)
  #update_quantized_state(cont, integrator, i)
  #for (j, istrue) in enumerate(integrator.deps[i, :])
  #  istrue && advance_time(cont, j, t)
  #end
  q₋ = deepcopy(integrator.q)
end

@enum ODE_TYPE non_stiff=0 stiff=1

struct QSS{T} <: Integrator
  order :: UInt8
  deps :: Matrix{Bool}
  q :: Vector{Taylor1}
  t :: Vector{Float64}
  function QSS{T}(model::Function, cont::Continuous, t::Float64, vec_x₀::Vector{Float64}; order::Number=4) where T
    f, deps = model()
    integrator = new(UInt8(order), deps, Vector{Taylor1}(), Vector{Float64}())
    zero_taylor = 0*Taylor1(Float64, integrator.order+1)
    for x₀ in vec_x₀
      push!(integrator.t, t)
      push!(integrator.q, x₀ + zero_taylor)
    end
    t₀ = t + Taylor1(Float64, integrator.order+1)
    vec_x = Vector{Taylor1}()
    for (i, x₀) in enumerate(vec_x₀)
      push!(vec_x, integrate(f[i](t₀, integrator.q, cont.p), x₀))
    end
    for i in 1:integrator.order-1
      for (j, x) in enumerate(vec_x)
        integrator.q[j] = copy(x)
      end
      for (j, x₀) in enumerate(vec_x₀)
        vec_x[j] = integrate(f[j](t₀, integrator.q, cont.p), x₀)
      end
    end
    for (i, x) in enumerate(vec_x)
      var = cont.vars[i]
      var.f = f[i]
      var.x = x
      var.t = t
      @callback step(var, cont, integrator)
      schedule(var)
    end
    integrator
  end
end

function Continuous(model::Function, env::Environment, x₀::Vector{Float64}, p::Vector{Float64}=Float64[]; order::Number=4)
  Continuous(model, QSS{non_stiff}, env, x₀, p; order=order)
end

function step(var::Variable, cont::Continuous, integrator::QSS)
  i = var.id
  env = environment(var)
  t = now(env)
  x₀ = advance_time(var, t)
  update_quantized_state(cont, integrator, i, t)
end

function advance_time(integrator::QSS, i::Int, t::Float64)
  q = integrator.q[i]
  Δt = t - integrator.t[i]
  integrator.q[i] = evaluate(q, Δt + Taylor1(q.order))
  integrator.t[i] = t
  integrator.q[i].coeffs[1]
end

function update_quantized_state(cont::Continuous, integrator::QSS{non_stiff}, i::UInt, t::Float64)
  integrator.q[i] = Taylor1(cont.vars[i].x.coeffs[1:integrator.order])
  integrator.t[i] = t
end

function update_quantized_state(cont::Continuous, integrator::QSS{stiff}, i::UInt, t::Float64)
  for (j, istrue) in enumerate(integrator.deps[i, :])
    istrue && advance_time(integrator, j, t)
  end
  q₋ = deepcopy(integrator.q)
end

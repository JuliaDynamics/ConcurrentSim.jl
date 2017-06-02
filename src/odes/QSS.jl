@enum ODE_TYPE non_stiff=0 stiff=1

struct QSS{T} <: Integrator
  order :: UInt8
  model :: Model
  p :: Vector{Float64}
  q :: Vector{Taylor1{Float64}}
  t :: Vector{Float64}
  Δrel :: Float64
  Δabs :: Float64
  function QSS{T}(model::Model, t::Float64, x₀::Vector{Float64}, p::Vector{Float64};
                  order::Number=4, Δrel::Float64=1e-6, Δabs::Float64=1e-6) where T
    qss = new(UInt8(order), model, p, Vector{Taylor1{Float64}}(), Vector{Float64}(), Δrel, Δabs)
    t₀ = t + Taylor1(Float64, order + 1)
    for q₀ in x₀
      push!(qss.t, t)
      push!(qss.q, q₀ + Taylor1(zeros(Float64, order + 1)))
    end
    for i in 1:order-1
      q = deepcopy(qss.q)
      for (j, q₀) in enumerate(x₀)
        qss.q[j] = integrate(model.f[j](t₀, q, p), q₀)
      end
    end
    qss
  end
end

function Continuous(model::Model, env::Environment, x₀::Vector{Float64}, p::Vector{Float64}=Float64[];
                    stiff::Bool=false, order::Number=4, Δrel::Number=1e-6, Δabs::Number=1e-6)
  stiff ? Continuous(model, env, QSS{SimJulia.stiff}, x₀, p; order=order, Δrel=float(Δrel), Δabs=float(Δabs)) :
          Continuous(model, env, QSS{SimJulia.non_stiff}, x₀, p; order=order, Δrel=float(Δrel), Δabs=float(Δabs))
end

function initial_values(qss::QSS, t::Float64)
  t₀ = t + Taylor1(Float64, qss.order + 1)
  x₀ = Vector{Taylor1{Float64}}()
  for (i, f) in enumerate(qss.model.f)
    push!(x₀, integrate(f(t₀, qss.q, qss.p), qss.q[i][1]))
  end
  x₀
end

function step(var::Variable, cont::Continuous, qss::QSS)
  t = now(environment(var))
  n = length(qss.model.f)
  i = var.id
  t₀ = t + Taylor1(Float64, qss.order + 1)
  x₀ = advance_time(var, t)
  update_quantized_state(qss, var, t)
  Δt = compute_next_time(qss, var)
  reset(var)
  schedule(var, Δt)
  for j in filter(j->qss.model.deps[j,i], 1:n)
    dep = cont.vars[j]
    x₀ = evaluate(dep.x, t - dep.t)
    dep.t = t
    advance_time(qss, j, t)
    for k in filter(k->qss.model.deps[j,k] && k!=j, 1:n)
      advance_time(qss, k, t)
    end
    dep.x = integrate(qss.model.f[j](t₀, qss.q, qss.p), x₀)
    Δt = recompute_next_time(qss, dep)
    reset(dep)
    schedule(dep, Δt)
  end
end

function advance_time(qss::QSS, i::Int, t::Float64)
  qss.q[i] = evaluate(qss.q[i], t - qss.t[i] + Taylor1(qss.order+0))
  qss.t[i] = t
  qss.q[i][1]
end

function update_quantized_state(qss::QSS{non_stiff}, var::Variable, t::Float64)
  i = var.id
  qss.q[i] = deepcopy(var.x)
  qss.q[i][end] = 0.0
  qss.t[i] = t
end

function update_quantized_state(qss::QSS{stiff}, var::Variable, t::Float64)
  i = var.id
  t₀ = t + Taylor1(Float64, qss.order + 1)
  x₀ = evaluate(var.x)
  Δq = max(qss.Δrel*x₀, qss.Δabs)
  for (j, istrue) in enumerate(qss.model.deps[i, :])
    istrue && advance_time(qss, j, t)
  end
  q̲  = deepcopy(qss.q)
  q̲[i] = Taylor1(zeros(order+1))+x₀-Δq
  x̲ = integrate(qss.model.f[i](t₀, q̲, qss.p), x₀)
  for k in 1:order-1
    q̲[i] = x̲-Δq
    x̲ = integrate(qss.model.f[i](t₀, q̲, qss.p), x₀)
  end
  q̲[i] = x̲-Δq
  q̲[i][end] = 0.0
  q̅ = deepcopy(qss.q)
  q̅[i] = Taylor1(zeros(order+1))+x₀+Δq
  x̅ = integrate(qss.model.f[i](t₀, q̅, qss.p), x₀)
  for k in 1:order-1
    q̅[i] = x̅+Δq
    x̅ = integrate(qss.model.f[i](t₀, q̅, qss.p), x₀)
  end
  q̅[i] = x̅+Δq
  q̅[i][end] = 0.0
  if x̲[end] * x̅[end] > 0.0
    if x̅[end] > 0.0
      var.x = deepcopy(x̅)
      q = deepcopy(q̅)
    else
      var.x = deepcopy(x̲)
      q = deepcopy(q̲)
    end
  else
    q̃ = brent(nth_derivative, x₀-Δq, x₀+Δq, qss, i; xtol=min(Δq/100, 1e-7))
    qss.q[i] = q̃ + Taylor1(zeros(Float64, order + 1))
    var.x = integrate(qss.model.f[i](t₀, qss.q, qss.p), x₀)
    for k in 1:order-1
      qss.q[i] = deepcopy(var.x)
      qss.q[i][1] = q̃
      var.x = integrate(qss.model.f[i](t₀, qss.q, qss.p), x₀)
    end
    qss.q[i][end] = 0.0
  end
end

function nth_derivative(q₀::Float64, qss::QSS{stiff}, i::UInt)
  t₀ = t + Taylor1(Float64, qss.order + 1)
  q = deepcopy(qss.q)
  q[i][2:end] = 0.0
  q[i][1] = q₀
  q[i] = integrate(qss.model.f[i](t₀, q, qss.p), q₀)
  for k in 1:order-1
    q[i] = integrate(qss.model.f[i](t₀, q, qss.p), q₀)
  end
  q[i][end]
end

function compute_next_time(qss::QSS{non_stiff}, var::Variable)
  x₀ = evaluate(var.x)
  Δq = max(qss.Δrel*x₀, qss.Δabs)
  (abs(Δq/var.x[end]))^(1.0/qss.order)
end

function compute_next_time(qss::QSS{stiff}, var::Variable)
  x₀ = evaluate(var.x)
  Δq = max(qss.Δrel*x₀, qss.Δabs)
  (abs(Δq/var.x[end]))^(1.0/qss.order)
end

function recompute_next_time(qss::QSS{non_stiff}, var::Variable)
  i = var.id
  x₀ = evaluate(var.x)
  Δq = max(qss.Δrel*x₀, qss.Δabs)
  p = (var.x-qss.q[i]).coeffs
  p[1] -= Δq
  neg = roots(p)
  p[1] += 2Δq
  pos = roots(p)
  select_root(neg, pos)
end

function select_root(neg::Vector{Complex{Float64}}, pos::Vector{Complex{Float64}})
  selected = Inf
  for v in filter(v->abs(imag(v)) < 1e-15 && real(v) >= 0, [neg..., pos...])
    selected = real(v) < selected ? real(v) : selected
  end
  selected
end

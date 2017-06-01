@enum ODE_TYPE non_stiff=0 stiff=1

struct QSS{T} <: Integrator
  order :: UInt8
  model :: Model
  p :: Vector{Float64}
  q :: Vector{Taylor1}
  t :: Vector{Float64}
  Δrel :: Float64
  Δabs :: Float64
  function QSS{T}(model::Model, t::Float64, x₀::Vector{Float64}, p::Vector{Float64};
                  order::Number=4, Δrel::Float64=1e-6, Δabs::Float64=1e-6) where T
    qss = new(UInt8(order), model, p, Vector{Taylor1}(), Vector{Float64}(), Δrel, Δabs)
    t₀ = t + Taylor1(Float64, order)
    for q₀ in x₀
      push!(qss.t, t)
      push!(qss.q, q₀ + Taylor1(zeros(Float64, order+1)))
    end
    for i in 1:order-1
      for (j, q₀) in enumerate(x₀)
        qss.q[j] = integrate(model.f[j](t₀, qss.q, p), q₀)
      end
    end
    qss
  end
end

function Continuous(model::Model, env::Environment, x₀::Vector{Float64}, p::Vector{Float64}=Float64[];
                    stiff::Bool=false, order::Number=4, Δrel::Float64=1e-6, Δabs::Float64=1e-6)
  stiff ? Continuous(model, env, QSS{SimJulia.stiff}, x₀, p; order=order, Δrel=Δrel, Δabs=Δabs) :
          Continuous(model, env, QSS{SimJulia.non_stiff}, x₀, p; order=order, Δrel=Δrel, Δabs=Δabs)
end

function initial_values(qss::QSS, t::Float64)
  t₀ = t + Taylor1(Float64, qss.order+0)
  x₀ = Vector{Taylor1}()
  for (i, f) in enumerate(qss.model.f)
    push!(x₀, integrate(f(t₀, qss.q, qss.p), qss.q[i][1]))
  end
  println(x₀)
  x₀
end

function step(var::Variable, cont::Continuous, qss::QSS)
  t = now(environment(var))
  n = length(qss.model.f)
  i = var.id
  t₀ = t + Taylor1(Float64, qss.order+0)
  x₀ = advance_time(var, t)
  update_quantized_state(qss, cont.vars, i, t)
  println(x₀)
  Δt = compute_next_time(var.x, max(qss.Δrel*x₀, qss.Δabs))
  schedule(var, cont, qss, Δt)
  for j in filter(j->qss.model.deps[j,i], 1:n)
    dep = cont.vars[j]
    x₀ = evaluate(dep.x, t - dep.t)
    dep.t = t
    for k in filter(k->qss.model.deps[j,k], 1:n)
      advance_time(qss, k, t)
    end
    dep.x = integrate(qss.model.f[j](t₀, qss.q, qss.p), x₀)
    Δt = recompute_next_time(qss, dep.x, qss.q[j], max(qss.Δrel*x₀, qss.Δabs))
    schedule(dep, cont, qss, Δt)
  end
end

function advance_time(qss::QSS, i::Int, t::Float64)
  qss.q[i] = evaluate(qss.q[i], t - qss.t[i] + Taylor1(qss.order+0))
  qss.t[i] = t
  qss.q[i][1]
end

function update_quantized_state(qss::QSS{non_stiff}, vars::Vector{Variable}, i::UInt, t::Float64)
  qss.q[i] = copy(vars[i].x)
  qss.q[i][end] = 0.0
  qss.t[i] = t
end

function update_quantized_state(qss::QSS{stiff}, vars::Vector{Variable}, i::UInt, t::Float64)
  for (j, istrue) in enumerate(qss.model.deps[i, :])
    istrue && advance_time(qss, j, t)
  end
  q₋ = deepcopy(qss.q)
end

function compute_next_time(x::Taylor1, Δq::Float64)
  (abs(Δq/x[end]))^(1.0/x.order)
end

function recompute_next_time(::QSS{non_stiff}, x::Taylor1, q::Taylor1, Δq::Float64)
  p = (x-q).coeffs
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

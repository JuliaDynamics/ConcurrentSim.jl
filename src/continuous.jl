mutable struct Variable <: AbstractEvent
  bev :: BaseEvent
  id :: UInt
  x :: Taylor1
  t :: Float64
  function Variable(env::Environment, id::Int, x::Taylor1, t::Float64)
    new(BaseEvent(env), id, x, t)
  end
end

function advance_time(var::Variable, t::Float64)
  var.x = evaluate(var.x, t - var.t + Taylor1(var.x.order))
  var.t = t
  var.x.coeffs[1]
end

function evaluate(var::Variable, t::Float64=now(environment(var)))
  evaluate(var.x, t - var.t)
end

struct Handler <: AbstractEvent
  bev :: BaseEvent
  function(env::Environment)
    new(BaseEvent(env))
  end
end


struct Continuous <: AbstractProcess
  bev :: BaseEvent
  vars :: Vector{Variable}
  function Continuous(env::Environment)
    new(BaseEvent(env), Vector{Variable}())
  end
end

function Continuous{I<:Integrator}(model::Model, env::Environment, ::Type{I},
    x₀::Vector{Float64}, p::Vector{Float64}=Float64[]; args...)
  cont = Continuous(env)
  t = now(env)
  integrator = I(model, now(env), x₀, p; args...)
  x = initial_values(integrator, t)
  for (i, x₀) in enumerate(x)
    push!(cont.vars, Variable(env, i, x₀, t))
  end
  for var in cont.vars
    @callback step(var, cont, integrator)
    schedule(var)
  end
  cont
end

macro continuous(expr::Expr)
  expr.head != :call && error("Expression is not a function call!")
  func = expr.args[1]
  params = Vector{Expr}()
  args = Vector{Any}()
  for i in 2:length(expr.args)
    if expr.args[i] isa Expr && expr.args[i].head == :parameters
      for ex in expr.args[i].args
        push!(params, ex)
      end
    else
      push!(args, expr.args[i])
    end
  end
  esc(:(Continuous($func(), $(args...); $(params...))))
end

function schedule(var::Variable, cont::Continuous, integrator::Integrator, Δt::Float64=0.0)
  var.bev = BaseEvent(environment(var))
  @callback step(var, cont, integrator)
  schedule(var, Δt)
end

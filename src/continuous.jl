mutable struct Variable <: AbstractEvent
  bev :: BaseEvent
  id :: UInt
  f :: Function
  x :: Taylor1
  t :: Float64
  function Variable(env::Environment, id::Int)
    new(BaseEvent(env), UInt(id))
  end
end

function advance_time(var::Variable, t::Float64)
  x = var.x
  Δt = t - var.t
  var.x = evaluate(x, Δt + Taylor1(x.order))
  var.t = t
  var.x.coeffs[1]
end

struct ZeroCrossing <: AbstractEvent

end

struct Continuous <: AbstractProcess
  bev :: BaseEvent
  vars :: Vector{Variable}
  p :: Vector{Float64}
  zcs :: Vector{ZeroCrossing}
  function Continuous(env::Environment, p::Vector{Float64})
    new(BaseEvent(env), Vector{Variable}(), p, Vector{ZeroCrossing}())
  end
end

function Continuous{I<:Integrator}(model::Function, ::Type{I}, env::Environment, x₀::Vector{Float64}, p::Vector{Float64}=Float64[]; args...)
  cont = Continuous(env, p)
  for i in 1:length(x₀)
    push!(cont.vars, Variable(env, i))
  end
  I(model, cont, now(env), x₀; args...)
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
  esc(:(Continuous($(func), $(args...); $(params...))))
end

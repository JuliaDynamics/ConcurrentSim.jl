mutable struct Variable <: AbstractEvent
  bev :: BaseEvent
  id :: UInt
  f :: Function
  x :: Taylor1
  t :: Float64
  function Variable(env::Environment, id::Int, f::Vector{Function}, x₀::Taylor1)
    new(BaseEvent(env), UInt(id), f[id], x₀, now(env))
  end
end

struct Continuous <: AbstractProcess
  bev :: BaseEvent
  vars :: Vector{Variable}
  p :: Vector{Float64}
  function Continuous(model::Function, env::Environment, x₀::Vector{Float64}, p::Vector{Float64}=Float64[]; integrator::Integrator=QSS())
    cont = new(BaseEvent(env), Vector{Variable}(), p)
    init(env, cont, integrator, model, x₀)
    cont
  end
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

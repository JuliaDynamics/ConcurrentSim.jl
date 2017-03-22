struct Continuous <: AbstractProcess
  bev :: BaseEvent
  f :: Vector{Function}
  order :: UInt8
  stiff :: Bool
  q :: Vector{Taylor1}
  x :: Vector{Taylor1}
  p :: Vector{Float64}
  function Continuous(func::Function, env::Environment, q::Vector{Float64}, p::Vector{Float64}=Float64[]; order::Number=4, stiff::Bool=false)
    cont = new(BaseEvent(env), func(), UInt8(order), stiff, Vector{Taylor1}(), Vector{Taylor1}(), p)
    for q₀ in q
      push!(cont.q, q₀ + Taylor1(Float64, order+1))
    end
    t = now(env) + Taylor1(Float64, order+1)
    for (i, q₀) in enumerate(q)
      push!(cont.x, integrate(cont.f[i](t, cont.q, cont.p), q₀))
    end
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

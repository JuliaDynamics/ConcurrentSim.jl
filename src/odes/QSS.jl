abstract type Quantizer end

struct DirectQuantizer <: Quantizer end

struct ImplicitQuantizer <: Quantizer end

struct QSS <: Integrator
  order :: UInt8
  quantizer :: Quantizer
  q :: Vector{Taylor1}
  t :: Vector{Float64}
  function QSS(;order::Number=4, stiff::Bool=false)
    quantizer = stiff ? ImplicitQuantizer() : DirectQuantizer()
    new(UInt8(order), quantizer, Vector{Taylor1}(), Vector{Float64}())
  end
end

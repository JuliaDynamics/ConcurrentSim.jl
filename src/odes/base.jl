abstract type Integrator end

struct Model
  f :: Vector{Function}
  p :: Vector{Float64}
  deps :: Matrix{Bool}
  function Model(f::Vector{Function}, deps::Matrix{Bool})
    new(f, Vector{Float64}(), deps)
  end
end

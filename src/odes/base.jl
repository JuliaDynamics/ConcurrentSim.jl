abstract type Integrator end

struct Model
  f :: Vector{Function}
  deps :: Matrix{Bool}
  function Model(f::Vector{Function}, deps::Matrix{Bool})
    new(f, deps)
  end
end

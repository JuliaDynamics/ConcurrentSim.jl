abstract type Integrator end

struct Model
  f :: Vector{Function}
  zc :: Vector{Function}
  deps :: Matrix{Bool}
  param_deps :: Matrix{Bool}
  function Model(f::Vector{Function}, zc::Vector{Function}, deps::Matrix{Bool}, param_deps::Matrix{Bool})
    new(f, zc, deps, param_deps)
  end
end

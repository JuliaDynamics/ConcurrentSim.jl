isdefined(Base, :__precompile__) && __precompile__()

module SimJulia
  using Base.Order
  using Base.Collections

  export Event

  include("events.jl")
end

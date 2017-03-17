isdefined(Base, :__precompile__) && __precompile__()

"""
Main module for SimJulia.jl – a combined continuous time / discrete event process oriented simulation framework for Julia.
"""
module SimJulia

  using DataStructures

  import Base.run, Base.now, Base.isless, Base.show
  import Base.(&), Base.(|)

  export AbstractEvent
  export value, state, environment
  export Simulation
  export run, now, active_process
  export Event, Timeout
  export succeed, fail, append_callback, @callback, remove_callback
  export Operator
  export (&), (|)

  include("base.jl")
  include("simulations.jl")
  include("events.jl")
  include("operators.jl")

end

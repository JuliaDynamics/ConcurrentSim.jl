isdefined(Base, :__precompile__) && __precompile__()

"""
  `SimJulia`

Main module for SimJulia.jl – a combined continuous time / discrete event process oriented simulation framework for Julia.
"""
module SimJulia
  using Base.Collections, Base.Dates

  import Base.show, Base.isless, Base.run, Base.now, Base.schedule, Base.yield
  import Base.&, Base.|, Base.+, Base.==

  export Event, Simulation
  export run, append_callback, schedule, schedule!
  export now, value, state
  export (&), (|)
  export idle, processing, triggered

  export Process
  export yield

  include("base.jl")
  include("process.jl")
end

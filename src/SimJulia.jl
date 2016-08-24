isdefined(Base, :__precompile__) && __precompile__()

"""
  `SimJulia`

Main module for SimJulia.jl – a combined continuous time / discrete event process oriented simulation framework for Julia.
"""
module SimJulia
  using Base.Collections, Base.Dates

  import Base.show, Base.isless, Base.run, Base.now, Base.schedule, Base.&, Base.|, Base.+, Base.==

  export Event, Simulation
  export run, append_callback, schedule, schedule!
  export now, value, state
  export (&), (|)
  export EVENT_IDLE, EVENT_TRIGGERED, EVENT_PROCESSING

  include("base.jl")
end

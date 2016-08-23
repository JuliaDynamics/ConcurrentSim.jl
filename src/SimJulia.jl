isdefined(Base, :__precompile__) && __precompile__()

"""
  `SimJulia`

Main module for SimJulia.jl – a combined continuous time / discrete event process oriented simulation framework for Julia.
"""
module SimJulia
  using Base.Collections, Base.Dates

  import Base.show, Base.isless, Base.run, Base.now, Base.schedule, Base.&, Base.+, Base.==

  export Event, run, append_callback, value, state, EVENT_IDLE, EVENT_TRIGGERED, EVENT_PROCESSING, (&)
  export Simulation, StopSimulation, now

  include("events.jl")
  include("simulations.jl")
end

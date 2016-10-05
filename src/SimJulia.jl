isdefined(Base, :__precompile__) && __precompile__()

"""
  `SimJulia`

Main module for SimJulia.jl – a combined continuous time / discrete event process oriented simulation framework for Julia.
"""
module SimJulia
  using Base.Collections, Base.Dates

  import Base.==, Base.+
  import Base.isless, Base.yield, Base.schedule, Base.run, Base.now, Base.eps
  import Base.show, Base.typemax

  export AbstractEvent
  export state, value, environment, append_callback, remove_callback
  export idle, triggered, processed
  export Event, Timeout
  export succeed, fail
  export Process, Interrupt
  export yield
  export SimulationTime
  export Simulation
  export now, run, active_process

  include("base.jl")
  include("events.jl")
  include("process.jl")
  include("time.jl")
  include("simulation.jl")
end

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
  export timeout
  export now, value, state
  export (&), (|)

  export Process
  export yield

  include("types.jl")
  include("exceptions.jl")
  include("events.jl")
  include("process.jl")
  include("time.jl")
  include("simulation.jl")
  include("utils.jl")
end

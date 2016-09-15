isdefined(Base, :__precompile__) && __precompile__()

"""
  `SimJulia`

Main module for SimJulia.jl – a combined continuous time / discrete event process oriented simulation framework for Julia.
"""
module SimJulia
  using Base.Collections, Base.Dates

  import Base.show, Base.isless, Base.run, Base.now, Base.schedule, Base.yield, Base.get
  import Base.&, Base.|, Base.+, Base.==

  export Event, Process, Simulation, Resource
  export run, append_callback, schedule, schedule!
  export timeout
  export yield
  export now, value
  export (&), (|)
  export get, put, release, request


  include("types.jl")
  include("exceptions.jl")
  include("events.jl")
  include("process.jl")
  include("time.jl")
  include("simulation.jl")
  include("utils.jl")
  include("resources/base.jl")
  include("resources/resource.jl")
end

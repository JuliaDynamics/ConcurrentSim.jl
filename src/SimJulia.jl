isdefined(Base, :__precompile__) && __precompile__()

"""
  `SimJulia`

Main module for SimJulia.jl – a combined continuous time / discrete event process oriented simulation framework for Julia.
"""
module SimJulia
  using Base.Collections, Base.Dates

  import Base.==, Base.+, Base.*, Base.&, Base.|
  import Base.isless, Base.yield, Base.schedule, Base.run, Base.now, Base.eps
  import Base.show, Base.typemax, Base.interrupt

  export AbstractEvent
  export state, value, environment, append_callback, remove_callback
  export Event, Timeout
  export succeed, fail
  export Operator
  export (&), (|)
  export Process
  export yield, interrupt
  export Simulation
  export run, now, active_process
  export Container, Resource, Store
  export Put, Get, Request, Release, cancel, capacity

  include("base.jl")
  include("events.jl")
  include("operators.jl")
  include("process.jl")
  include("time.jl")
  include("simulation.jl")
  include("resources/base.jl")
  include("resources/containers.jl")
  include("resources/stores.jl")
end

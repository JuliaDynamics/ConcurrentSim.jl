isdefined(Base, :__precompile__) && __precompile__()

"""
Main module for SimJulia.jl – a discrete event process oriented simulation framework for Julia.
"""
module SimJulia

  using DataStructures
  using Dates
  using ResumableFunctions

  import Base.run, Base.isless, Base.show, Base.yield, Base.get
  import Base.(&), Base.(|)
  import Dates.now

  export AbstractEvent, Environment, value, state, environment
  export Event, succeed, fail, @callback, remove_callback
  export timeout
  export Operator, (&), (|)
  export AbstractProcess, Simulation, run, now, active_process, StopSimulation
  export Process, @process, interrupt
  export Container, Resource, Store, put, get, request, release, cancel
  export nowDatetime

  include("base.jl")
  include("events.jl")
  include("operators.jl")
  include("simulations.jl")
  include("processes.jl")
  include("resources/base.jl")
  include("resources/containers.jl")
  include("resources/stores.jl")
  include("utils/time.jl")
end

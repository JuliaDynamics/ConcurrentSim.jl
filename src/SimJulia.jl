isdefined(Base, :__precompile__) && __precompile__()

"""
Main module for SimJulia.jl – a combined continuous time / discrete event process oriented simulation framework for Julia.
"""
module SimJulia
  using Base.Collections, Base.Dates
  using DataStructures

  import Base.==, Base.+, Base.*, Base.&, Base.|
  import Base.isless, Base.yield, Base.schedule, Base.run, Base.now, Base.eps
  import Base.show, Base.typemax, Base.interrupt

  export AbstractEvent
  export state, value, environment, append_callback, remove_callback
  export Event, Timeout
  export succeed, fail
  export Operator
  export (&), (|)
  export FiniteStateMachine, @stateful, @yield
  export Coroutine, @Coroutine
  export Process, @Process
  export interrupt
  export Simulation, StopSimulation
  export run, now, active_process
  export Container, Resource, Store
  export Put, Get, Request, Release, cancel, capacity, @Request

  include("base.jl")
  include("events.jl")
  include("operators.jl")
  include("time.jl")
  include("simulation.jl")
  include("coroutines/utils.jl")
  include("coroutines/transforms.jl")
  include("coroutines/macro.jl")
  include("coroutines.jl")
  include("processes/base.jl")
  include("processes.jl")
  include("resources/base.jl")
  include("resources/containers.jl")
  include("resources/stores.jl")
end

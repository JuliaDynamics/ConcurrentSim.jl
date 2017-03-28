isdefined(Base, :__precompile__) && __precompile__()

"""
Main module for SimJulia.jl – a combined continuous time / discrete event process oriented simulation framework for Julia.
"""
module SimJulia

  using DataStructures
  using Base.Dates
  using TaylorSeries

  import Base.run, Base.now, Base.isless, Base.show, Base.interrupt, Base.yield
  import Base.(&), Base.(|)
  import TaylorSeries.integrate

  export AbstractEvent
  export value, state, environment
  export Event, Timeout
  export succeed, fail, @callback, remove_callback
  export Operator
  export (&), (|)
  export Simulation
  export run, now, active_process
  export nowDatetime
  export Process, @process
  export yield, interrupt
  export FiniteStateMachine, @stateful, @yield
  export Coroutine, @coroutine
  export Container, Resource, Store
  export Put, Get, Request, Release, cancel, capacity, request, @request
  export Continuous, Variable
  export @model, @continuous

  include("base.jl")
  include("events.jl")
  include("utils/operators.jl")
  include("simulations.jl")
  include("utils/time.jl")
  include("tasks/base.jl")
  include("processes.jl")
  include("finitestatemachines/utils.jl")
  include("finitestatemachines/transforms.jl")
  include("finitestatemachines/macros.jl")
  include("coroutines.jl")
  include("resources/base.jl")
  include("resources/containers.jl")
  include("resources/stores.jl")
  include("odes/base.jl")
  include("odes/macros.jl")
  include("odes/QSS.jl")
  include("continuous.jl")
  include("odes/utils.jl")
  include("odes/commons.jl")
end

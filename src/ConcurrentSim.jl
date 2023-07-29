"""
Main module for ConcurrentSim.jl – a discrete event process oriented simulation framework for Julia.
"""
module ConcurrentSim

  using DataStructures
  using Dates
  using ResumableFunctions

  import Base: run, isless, show, yield, get, put!, isready, islocked, unlock, lock, trylock, &, |
  import Dates: now

  export AbstractEvent, Environment, value, state, environment
  export Event, succeed, fail, @callback, remove_callback
  export timeout
  export Operator, (&), (|), AllOf, AnyOf
  export @resumable, @yield
  export AbstractProcess, Simulation, run, now, active_process, StopSimulation
  export Process, @process, interrupt
  export Container, Resource, Store, put!, get, cancel
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
  include("deprecated.jl")
end

isdefined(Base, :__precompile__) && __precompile__()

"""
Main module for SimJulia.jl – a combined continuous time / discrete event process oriented simulation framework for Julia.
"""
module SimJulia

  using DataStructures

  import Base.run, Base.now, Base.isless, Base.show, Base.interrupt, Base.yield
  import Base.(&), Base.(|)

  export AbstractEvent
  export value, state, environment
  export Simulation
  export run, now, active_process
  export Event, Timeout
  export succeed, fail, append_callback, @callback, remove_callback
  export Operator
  export (&), (|)
  export Process, @process
  export yield, interrupt
  export FiniteStateMachine, @stateful, @yield, iscoroutinedone
  export Coroutine, @coroutine

  include("base.jl")
  include("simulations.jl")
  include("events.jl")
  include("operators.jl")
  include("tasks/base.jl")
  include("processes.jl")
  include("finitestatemachines/utils.jl")
  include("finitestatemachines/transforms.jl")
  include("finitestatemachines/base.jl")
  include("coroutines.jl")
end

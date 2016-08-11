isdefined(Base, :__precompile__) && __precompile__()

module SimJulia
  using Base.Order
  using Base.Collections

  import Base.show, Base.isless, Base.run, Base.now, Base.schedule, Base.step

  export Environment, Event, run, append_callback
  export Simulation, StopSimulation, now, schedule

  include("base.jl")
  include("simulation.jl")
end

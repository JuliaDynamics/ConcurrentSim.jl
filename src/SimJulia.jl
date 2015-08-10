module SimJulia
  using Base.Order
  using Base.Collections
  import Base.show, Base.isless, Base.yield, Base.run, Base.count
  if VERSION >= v"0.4-"
    import Base.now, Base.step, Base.&, Base.|
  end
  export BaseEvent, BaseEnvironment, now
  export Event, Timeout, StopIteration, succeed, fail, triggered, processed, value, append_callback, environment, Timeout, run
  export Condition, AllOf, AnyOf, (&), (|)
  export Process, Interrupt, InterruptException, yield, active_process, cause, msg
  export Environment, step
  export start_delayed
  export Resource, Preempted, Request, Release, usage_since, count
  export Container, Get, Put, capacity, level
  include("base.jl")
  include("events.jl")
  include("conditions.jl")
  include("processes.jl")
  include("environments.jl")
  include("util.jl")
  include("resources.jl")
  include("containers.jl")
end

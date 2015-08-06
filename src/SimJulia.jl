module SimJulia
  using Base.Order
  using Base.Collections
  import Base.show, Base.isless, Base.interrupt, Base.yield, Base.run, Base.interrupt, Base.count
  if VERSION >= v"0.4-"
    import Base.now, Base.step, Base.get, Base.&, Base.|
  end
  export BaseEvent, BaseEnvironment, now
  export Event, StopIteration, succeed, fail, triggered, processed, value, append_callback, environment, timeout, run
  export condition, all_of, any_of, (&), (|)
  export Process, Interrupt, yield, active_process, interrupt, cause, msg
  export Environment, step
  export start_delayed
  export Resource, Preempted, request, release, usage_since, count
  export Container, get, put, capacity, level
  include("base.jl")
  include("events.jl")
  include("conditions.jl")
  include("processes.jl")
  include("environments.jl")
  include("util.jl")
  include("resources.jl")
  include("containers.jl")
end

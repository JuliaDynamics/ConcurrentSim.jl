module SimJulia
  using Base.Order
  using Base.Collections

  import Base.show, Base.isless, Base.yield, Base.run, Base.count, Base.isless
  if VERSION >= v"0.4-"
    import Base.now, Base.step, Base.&, Base.|
  end
  import Base.Collections.peek

  export AbstractEvent, run, succeed, fail, trigger, triggered, processed, value, append_callback
  export Event, Timeout, EventOperator, AllOf, AnyOf, (&), (|)
  export Process, Interruption, yield, is_process_done, cause
  export Environment, step, peek, now, active_process
  export DelayedProcess
  export Resource, Preempted, Request, Release, cancel, by, usage_since, capacity, count
  export Container, Get, Put, level

  include("base.jl")
  include("events.jl")
  include("processes.jl")
  include("environments.jl")
  include("util.jl")
  include("resources.jl")
  include("containers.jl")
end

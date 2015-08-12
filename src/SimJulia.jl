module SimJulia
  using Base.Order
  using Base.Collections
  import Base.show, Base.isless, Base.yield, Base.run, Base.count, Base.exit, Base.done, Base.convert
  if VERSION >= v"0.4-"
    import Base.now, Base.step, Base.&, Base.|
  end
  import Base.Collections.peek
  export BaseEvent, BaseEnvironment, StopSimulation, EmptySchedule
  export Event, Timeout, EventProcessed, succeed, fail, triggered, processed, value, append_callback, run, exit
  export Condition, AllOf, AnyOf, (&), (|)
  export Process, Interrupt, InterruptException, yield, active_process, cause, msg, done
  export Environment, step, peek, now
  export DelayedProcess
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

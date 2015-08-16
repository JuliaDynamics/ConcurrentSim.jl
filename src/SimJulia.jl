module SimJulia
  using Base.Collections

  import Base.show, Base.isless, Base.yield, Base.run, Base.exit, Base.done, Base.convert
  if VERSION >= v"0.4-"
    import Base.now, Base.step, Base.&, Base.|
  end
  import Base.Collections.peek

  export StopSimulation, EmptySchedule
  export Event, Timeout, EventTriggered, EventProcessed, succeed, fail, trigger, triggered, processed, value, append_callback, run, exit
  export Condition, AllOf, AnyOf, (&), (|)
  export Process, Interrupt, InterruptException, yield, active_process, cause, msg, done
  export Environment, step, peek, now
  export DelayedProcess

  include("base.jl")
  include("events.jl")
  include("conditions.jl")
  include("processes.jl")
  include("environments.jl")
  include("util.jl")

  module Resources
    using Base.Order
    using Base.Collections
    using SimJulia

    import Base.count, Base.isless

    export Resource, Preempted, Request, Release, cancel, by, usage_since, capacity, count

    include("resources.jl")
  end

  module Containers
    using Base.Order
    using Base.Collections
    using SimJulia

    import Base.isless, SimJulia.Resources.capacity

    export Container, Get, Put, capacity, level

    include("containers.jl")
  end
end

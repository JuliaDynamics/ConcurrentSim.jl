module SimJulia
  import Base.show, Base.isless, Base.interrupt, Base.yield, Base.run, Base.interrupt, Base.count
  if VERSION >= v"0.4-"
    import Base.now
  end
  export BaseEvent
  export Environment, Event, timeout, Process
  export interrupt, Interrupt
  export condition, all_of, any_of
  export Resource, Preempted, request, release
  export run, now
  export succeed, fail, yield, triggered, processed, value, append_callback, environment
  export cause, msg, usage_since, count, capacity
  export (&), (|)
  include("base.jl")
  include("core.jl")
  include("interrupts.jl")
  include("conditions.jl")
  include("resources.jl")
end

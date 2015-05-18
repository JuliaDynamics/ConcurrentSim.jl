module SimJulia
  import Base.show, Base.isless, Base.interrupt, Base.yield, Base.run
  if VERSION >= v"0.4-"
    import Base.now, Base.Condition
  end
  export BaseEvent
  export Environment, Event, Timeout, Process
  export Interrupt, SimInterruptException
  export Condition, AllOf, AnyOf
  export run, now
  export succeed, fail, yield, triggered, processed, value, append_callback, environment
  export cause, msg
  export (&), (|)
  include("base.jl")
  include("core.jl")
  include("interrupts.jl")
  include("conditions.jl")
end

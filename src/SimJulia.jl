module SimJulia
  import Base.show, Base.isless, Base.interrupt, Base.yield, Base.run
  if VERSION >= v"0.4-"
    import Base.now
  end
  export BaseEvent, BaseEnvironment
  export Environment, Event, Timeout, Process
  export Interrupt, InterruptException
  export Condition, AllOf, AnyOf
  export run, succeed, fail, yield
  export triggered, processed
  export now, append_callback, value, cause
  export (&), (|)
  include("base.jl")
  include("core.jl")
  include("interrupts.jl")
  include("conditions.jl")
end

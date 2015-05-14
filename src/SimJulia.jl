module SimJulia
  import Base.show, Base.isless, Base.interrupt, Base.yield, Base.run
  if VERSION >= v"0.4-"
    import Base.now
  end
  export BaseEvent, BaseEnvironment
  export Environment, Event, Timeout, Process, Condition, Interrupt, InterruptException
  export run, succeed, fail, yield
  export triggered, processed
  export now, append_callback, value, cause
  export (&), (|)
  include("core.jl")
end

module SimJulia
  import Base.show, Base.isless, Base.interrupt, Base.yield
  export Environment, Event, Timeout, Process, Condition, Interrupt
  export run, succeed, fail, yield
  export triggered, processed
  export now, add, value, cause
  include("core.jl")
end

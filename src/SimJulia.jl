module SimJulia
  import Base.show, Base.isless, Base.interrupt
  export Environment, Event, Timeout, Process
  export run, succeed, fail, yield
  export triggered
  export now, active_process, add, value
  include("core.jl")
end

testpath(f) = joinpath(dirname(@__FILE__), f)

for test_file in [
  "base.jl",
  "events.jl",
  "utils/operators.jl",
  "simulations.jl",
  "utils/time.jl",
  "tasks/base.jl",
  "processes.jl",
  "coroutines.jl",
  "containers.jl",
  "stores.jl",
  "continuous.jl",]
  include(testpath(test_file))
end

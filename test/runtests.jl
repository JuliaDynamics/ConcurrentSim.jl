testpath(f) = joinpath(dirname(@__FILE__), f)

for test_file in [
  "base.jl",
  "simulations.jl",
  "events.jl",
  "operators.jl",
  "tasks/base.jl",
  "processes.jl",
  "finitestatemachines/utils.jl",
  "finitestatemachines/transforms.jl",
  "coroutines.jl"]
  include(testpath(test_file))
end

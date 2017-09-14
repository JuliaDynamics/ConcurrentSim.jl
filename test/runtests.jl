testpath(f) = joinpath(dirname(@__FILE__), f)

for test_file in [
  "base.jl",
  "events.jl",
  "operators.jl",
  "simulations.jl",
  "utils/time.jl",
  "old/processes.jl",
  "processes.jl",
  "resources/containers.jl",
  "resources/stores.jl",
  ]
  include(testpath(test_file))
end

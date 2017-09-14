testpath(f) = joinpath(dirname(@__FILE__), f)

for test_file in [
  "base.jl",
  "events.jl",
  "operators.jl",
  "simulations.jl",
  "utils/time.jl",
  "old/processes.jl",
  "coroutines.jl",
  "containers.jl",
  "stores.jl",
  ]
  include(testpath(test_file))
end

workspace()
testpath(f) = joinpath(dirname(@__FILE__), f)

for test_file in [
  "finitestatemachines/test_transforms.jl",
  "finitestatemachines/test_utils.jl",
  "test_base.jl",
  "test_events.jl",
  "test_operators.jl",
  "test_simulation.jl",
  "test_processes.jl",
  "test_coroutines.jl",
  "test_containers.jl",
  "test_stores.jl",
  ]
  include(testpath(test_file))
end

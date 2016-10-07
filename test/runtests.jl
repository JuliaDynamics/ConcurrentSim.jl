testpath(f) = joinpath(dirname(@__FILE__), f)

for test_file in [
  "test_base.jl",
  "test_events.jl",
  "test_operators.jl",
  "test_simulation.jl",
  "test_process.jl",
  "test_containers.jl",]
  include(testpath(test_file))
end

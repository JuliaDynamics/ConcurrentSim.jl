testpath(f) = joinpath(dirname(@__FILE__), f)

for test_file in [
  "test_base.jl",
  "test_events.jl",
  "test_simulation.jl",
  "test_process.jl",]
  include(testpath(test_file))
end

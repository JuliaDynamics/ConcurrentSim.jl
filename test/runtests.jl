testpath(f) = joinpath(dirname(@__FILE__),f)

for test_file in [
  "test_events.jl",
  "test_processes.jl",]
  include(testpath(test_file))
end

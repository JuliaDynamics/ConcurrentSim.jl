testpath(f) = joinpath(Pkg.dir("SimJulia"),"test",f)

for test_file in [
  "test_events.jl",
  "test_processes.jl",
  "test_conditions.jl"]
  include(testpath(test_file))
end

examplespath(f) = joinpath(Pkg.dir("SimJulia"),"examples",f)

for example_file in [
  "simpy_welcome.jl",
  "simpy_10min_1.jl",
  "simpy_10min_2.jl",
  "simpy_10min_3.jl"]
  include(examplespath(example_file))
end

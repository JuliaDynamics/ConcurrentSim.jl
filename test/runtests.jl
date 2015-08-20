testpath(f) = joinpath(Pkg.dir("SimJulia"),"test",f)

for test_file in [
  "test_events.jl",
  "test_processes.jl",
  "test_event_operators.jl",
  "test_resources.jl",
  "test_containers.jl"]
  include(testpath(test_file))
end

examplespath(f) = joinpath(Pkg.dir("SimJulia"),"examples",f)

for example_file in [
  "simpy_welcome.jl",
  "simpy_10min_1.jl",
  "simpy_10min_2.jl",
  "simpy_10min_3.jl",
  "simpy_10min_4.jl",
  "simpy_basics.jl",
  "simpy_environments_1.jl",
  "simpy_environments_2.jl",
  "simpy_environments_3.jl",
  "simpy_events_1.jl",
  "simpy_events_2.jl",
  "simpy_events_3.jl",
  "simpy_events_4.jl",
  "simpy_events_5.jl",
  "simpy_events_6.jl",
  "simpy_processes_1.jl",
  "simpy_processes_2.jl",
  "simpy_processes_3.jl",
  "simpy_resources_1.jl",
  "simpy_resources_2.jl",
  "simpy_resources_3.jl",
  "simpy_resources_4.jl",
  "simpy_resources_5.jl",
  "simpy_resources_6.jl",
  "simpy_examples_1.jl",
  "simpy_examples_2.jl",
  "simpy_examples_3.jl"]
  include(examplespath(example_file))
end

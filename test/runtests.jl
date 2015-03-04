testpath(f) = joinpath(Pkg.dir("SimJulia"),"test",f)

for test_file in [
    "test_events.jl",
    "test_processes.jl",
    "test_conditions.jl"]
    include(testpath(test_file))
end

using BenchmarkTools, Random

include("processes_MM1.jl")
include("processes_fibonnaci.jl")

const SUITE = BenchmarkGroup()
SUITE["MM1"] = @benchmarkable test_mm1(100.0) setup=(Random.seed!(1234)) evals=1
SUITE["Fibonacci"] = @benchmarkable run_test()

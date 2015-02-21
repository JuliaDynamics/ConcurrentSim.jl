testpath(f) = joinpath(Pkg.dir("SimJulia"),"test",f)

# Bank problems
for bank_file in [
    "bank_01.jl",
    "bank_02.jl",
    "bank_03.jl",
    "bank_05.jl",
    "bank_06.jl",
    "bank_07.jl",
    "bank_08.jl",
    "bank_09.jl",
    "bank_10.jl",
    "bank_20.jl",
    "bank_23.jl",
    "bank_24.jl"]
    include(testpath(bank_file))
end

# Example problems
for ex_file in 1:18
    include(testpath("example_$(ex_file).jl"))
end

# Leftovers
include("cellular_automata.jl")
include("continuous_1.jl")
include("continuous_2.jl")
include("continuous_3.jl")
include("continuous_5.jl")
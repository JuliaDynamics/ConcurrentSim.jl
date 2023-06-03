using ResumableFunctions
using Test
using SafeTestsets

function doset(descr)
    if length(ARGS) == 0
        return true
    end
    for a in ARGS
        if occursin(lowercase(a), lowercase(descr))
            return true
        end
    end
    return false
end

macro doset(descr)
    quote
        if doset($descr)
            @safetestset $descr begin
                include("test_"*$descr*".jl")
            end
        end
    end
end

println("Starting tests with $(Threads.nthreads()) threads out of `Sys.CPU_THREADS = $(Sys.CPU_THREADS)`...")

@doset "base"
@doset "events"
@doset "operators"
@doset "simulations"
@doset "processes"
@doset "resources_containers"
@doset "resources_stores"
@doset "utils_time"
VERSION >= v"1.9" && @doset "doctests"
VERSION >= v"1.9" && @doset "aqua"
get(ENV,"JET_TEST","")=="true" && @doset "jet"

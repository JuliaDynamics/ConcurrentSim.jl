# Overview

SimJulia is a discrete-event process-oriented simulation framework written in [Julia](http://julialang.org/) inspired by the Python library [SimPy](https://simpy.readthedocs.io/). Its process dispatcher is based on semi-coroutines scheduling as implemented in [ResumableFunctions](https://github.com/BenLauwens/ResumableFunctions.jl.git). A `Process` in SimJulia is defined by a `@resumable function` yielding `Events`. SimJulia provides three types of shared resources to model limited capacity congestion points: `Resources`, `Containers` and `Stores`. The API is modeled after the SimPy API but some specific Julia semantics are used.

The documentation contains a tutorial, topical guides explaining key concepts, a number of examples and the API reference. The tutorial, the topical guides and some examples are borrowed from SimPy to allow a direct comparison and an easy migration path for users. The differences between SimJulia and SimPy are clearly documented.

## Example

A short example simulating two clocks ticking in different time intervals looks like this:

```jldoctest
julia> using ResumableFunctions

julia> using SimJulia

julia> @resumable function clock(sim::Simulation, name::String, tick::Float64)
         while true
           println(name, " ", now(sim))
           @yield Timeout(sim, tick)
         end
       end
clock (generic function with 1 method)

julia> sim = Simulation()
SimJulia.Simulation time: 0.0 active_process: nothing

julia> @process clock(sim, "fast", 0.5)
SimJulia.Process 1

julia> @process clock(sim, "slow", 1.0)
SimJulia.Process 3

julia> run(sim, 2)
fast 0.0
slow 0.0
fast 0.5
slow 1.0
fast 1.0
fast 1.5
```

## Installation

SimJulia is a registered package and can be installed by running:
```julia
Pkg.add("SimJulia")
```

## Authors

* Ben Lauwens, Royal Military Academy, Brussels, Belgium.

## License

SimJulia is licensed under the MIT "Expat" License.
SimJulia
========

**SimJulia** is a discrete event process oriented simulation framework written in [Julia](http://julialang.org/) inspired by the Python library [SimPy](https://simpy.readthedocs.io/).

#### Build Status

[![Build Status](https://travis-ci.org/BenLauwens/SimJulia.jl.svg?branch=master)](https://travis-ci.org/BenLauwens/SimJulia.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/djuiegytv44pr54c/branch/master?svg=true)](https://ci.appveyor.com/project/BenLauwens/simjulia-jl)


#### Coverage

[![Coverage Status](https://coveralls.io/repos/BenLauwens/SimJulia.jl/badge.svg?branch=master)](https://coveralls.io/r/BenLauwens/SimJulia.jl?branch=master)
[![codecov.io](http://codecov.io/github/BenLauwens/SimJulia.jl/coverage.svg?branch=master)](http://codecov.io/github/BenLauwens/SimJulia.jl?branch=master)


#### Installation

SimJulia.jl is a [registered package](http://pkg.julialang.org), and is simply installed by running

```julia
julia> Pkg.add("SimJulia")
```


#### Package Evaluator

[![SimJulia](http://pkg.julialang.org/badges/SimJulia_0.5.svg)](http://pkg.julialang.org/?pkg=SimJulia&ver=0.5)
[![SimJulia](http://pkg.julialang.org/badges/SimJulia_0.6.svg)](http://pkg.julialang.org/?pkg=SimJulia&ver=0.6)

#### Documentation

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://BenLauwens.github.io/SimJulia.jl/stable)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://BenLauwens.github.io/SimJulia.jl/latest)


#### Release Notes

* Version 0.5 does no longer integrate a continuous time solver. A continuous time solver using SimJulia as its discrete event engine can be found in the repository [QuantizedStateSystems](https://github.com/BenLauwens/QuantizedStateSystems.jl.git).
* Starting from version 0.4.1, [ResumableFunctions](https://github.com/BenLauwens/ResumableFunctions.jl.git) is a separate package exporting the `resumable` and `yield` macro and it is a dependency for `SimJulia`. Users have to take into account the following syntax change:
  * `@yield return arg` is replaced by `@yield arg`
* Version 0.4 only supports Julia v0.6 and above. It is a complete rewrite: more julian and less pythonic.
* The discrete event features are on par with version 0.3 and following features are added:
  * Scheduling of events can be done with `Base.Dates.Datetime` and `Base.Dates.Period`:
  ```julia
  using SimJulia
  using Base.Dates

  function datetimetest(sim::Simulation)
    println(nowDatetime(sim))
    yield(Timeout(sim, Day(2)))
    println(nowDatetime(sim))
  end

  datetime = now()
  sim = Simulation(datetime)
  @process datetimetest(sim)
  run(sim, datetime+Month(3))
  ```
  * Two ways of making `Processes` are provided:
    - using the existing concept of `Tasks`:
    ```julia
    function fibonnaci(sim::Simulation)
      a = 0.0
      b = 1.0
      while true
        println(now(sim), ": ", a)
        yield(Timeout(sim, 1))
        a, b = b, a+b
      end
    end

    sim = Simulation()
    @process fibonnaci(sim)
    run(sim, 10)
    ```
    - using a novel finite-statemachine approach:
    ```julia
    using ResumableFunctions

    @resumable function fibonnaci(sim::Simulation)
      a = 0.0
      b = 1.0
      while true
        println(now(sim), ": ", a)
        @yield Timeout(sim, 1)
        a, b = b, a+b
      end
    end

    sim = Simulation()
    @coroutine fibonnaci(sim)
    run(sim, 10)
    ```
  * Documentation is automated with [Documenter.jl](https://github.com/JuliaDocs/Documenter.jl). (WIP)


#### Todo

* Transparent output processing.
* Automatically running a large number of simulations (over a parameter space) on a cluster to do simulation based optimisation.


#### Authors

* Ben Lauwens, Royal Military Academy, Brussels, Belgium


#### License

[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](LICENSE.md)

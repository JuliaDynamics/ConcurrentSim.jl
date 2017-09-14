# SimJulia

A discrete event process oriented simulation framework written in [Julia](http://julialang.org/) inspired by the Python library [SimPy](https://simpy.readthedocs.io/).

## Build Status & Coverage

[![Build Status](https://travis-ci.org/BenLauwens/SimJulia.jl.svg?branch=master)](https://travis-ci.org/BenLauwens/SimJulia.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/djuiegytv44pr54c/branch/master?svg=true)](https://ci.appveyor.com/project/BenLauwens/simjulia-jl)
[![Coverage Status](https://coveralls.io/repos/github/BenLauwens/SimJulia.jl/badge.svg?branch=master)](https://coveralls.io/github/BenLauwens/SimJulia.jl?branch=master)
[![codecov](https://codecov.io/gh/BenLauwens/SimJulia.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/BenLauwens/SimJulia.jl)

## Installation

[![SimJulia](http://pkg.julialang.org/badges/SimJulia_0.3.svg)](http://pkg.julialang.org/?pkg=SimJulia&ver=0.3)
[![SimJulia](http://pkg.julialang.org/badges/SimJulia_0.4.svg)](http://pkg.julialang.org/?pkg=SimJulia&ver=0.4)
[![SimJulia](http://pkg.julialang.org/badges/SimJulia_0.5.svg)](http://pkg.julialang.org/?pkg=SimJulia&ver=0.5)
[![SimJulia](http://pkg.julialang.org/badges/SimJulia_0.6.svg)](http://pkg.julialang.org/?pkg=SimJulia&ver=0.6)

SimJulia.jl is a [registered package](http://pkg.julialang.org), and is installed by running

```julia
julia> Pkg.add("SimJulia")
```

## Documentation

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://BenLauwens.github.io/SimJulia.jl/stable)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://BenLauwens.github.io/SimJulia.jl/latest)

## License

[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](LICENSE.md)

## Authors

* Ben Lauwens, Royal Military Academy, Brussels, Belgium.

## Contributing

* To discuss problems or feature requests, file an issue. For bugs, please include as much information as possible, including operating system, julia version, and version of the dependencies: `DataStructures` and `ResumableFunctions`.
* To contribute, make a pull request. Contributions should include tests for any new features/bug fixes.

## Release Notes

* 2017: v0.5
  * The old way of making processes is deprecated in favor of the semi-coroutine approach as implemented in [ResumableFunctions](https://github.com/BenLauwens/ResumableFunctions.jl.git). The `@process` macro replaces the `@coroutine` macro. The old `@process` macro is temporarily renamed `@oldprocess` and will be removed when the infrastructure supporting the `produce` and the `consume` functions is no longer available in Julia. (DONE)
  * This version no longer integrates a continuous time solver. A continuous simulation framework based on [DISCO](http://www.akira.ruc.dk/~keld/research/DISCO/) and inspired by the standalone [QSS](https://sourceforge.net/projects/qssengine/) solver using SimJulia as its discrete-event engine can be found in the repository [QuantizedStateSystems](https://github.com/BenLauwens/QuantizedStateSystems.jl.git) (WIP):
  * Documentation is automated with [Documenter.jl](https://github.com/JuliaDocs/Documenter.jl) (WIP: Overview and Tutorial OK).
* 2017: v0.4.1, the `resumable` and `yield` macro are put in a seperate package [ResumableFunctions](https://github.com/BenLauwens/ResumableFunctions.jl.git): 
  * Users have to take into account the following syntax change: `@yield return arg` is replaced by `@yield arg`.
* 2017: v0.4 only supports Julia v0.6 and above. It is a complete rewrite: more julian and less pythonic. The discrete event features are on par with v0.3 (SimPy v3) and following features are added:
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
  * A continuous time solver based on the standalone [QSS](https://sourceforge.net/projects/qssengine/) solver is implemented. Only non-stiff systems can be solved efficiently.
* 2015: v0.3 synchronizes the API with SimPy v3 and is Julia v0.3, v0.4 and v0.5 compatible:
  * Documentation is available at [readthedocs](http://simjuliajl.readthedocs.org/en/latest/).
  * The continuous time solver is not implemented.
* 2014: v0.2 introduces a continuous time solver inspired by the Simula library [DISCO](http://www.akira.ruc.dk/~keld/research/DISCO/) and is Julia v0.2 and v0.3 compatible.
* 2013: v0.1 is a Julia clone of SimPy v2 and is Julia v0.2 compatible.

## Todo

* Transparent statistics gathering for resources.

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
[![SimJulia](http://pkg.julialang.org/badges/SimJulia_0.7.svg)](http://pkg.julialang.org/?pkg=SimJulia&ver=0.7)
[![SimJulia](http://pkg.julialang.org/badges/SimJulia_1.0.svg)](http://pkg.julialang.org/?pkg=SimJulia&ver=1.0)

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

* v0.6 (2018)
  * adds support for Julia v0.7.
  * the `@oldprocess` macro and the `produce` / `consume` functions are removed because they are no longer supported.
* v0.5 (2018)
  * The old way of making processes is deprecated in favor of the semi-coroutine approach as implemented in [ResumableFunctions](https://github.com/BenLauwens/ResumableFunctions.jl.git). The `@process` macro replaces the `@coroutine` macro. The old `@process` macro is temporarily renamed `@oldprocess` and will be removed when the infrastructure supporting the `produce` and the `consume` functions is no longer available in Julia. (DONE)
  * This version no longer integrates a continuous time solver. A continuous simulation framework based on [DISCO](http://www.akira.ruc.dk/~keld/research/DISCO/) and inspired by the standalone [QSS](https://sourceforge.net/projects/qssengine/) solver using SimJulia as its discrete-event engine can be found in the repository [QuantizedStateSystems](https://github.com/BenLauwens/QuantizedStateSystems.jl.git) (WIP):
  * Documentation is automated with [Documenter.jl](https://github.com/JuliaDocs/Documenter.jl) (WIP: Overview and Tutorial OK).
* v0.4.1 (2017)
  * the `@resumable` and `@yield` macros are put in a seperate package [ResumableFunctions](https://github.com/BenLauwens/ResumableFunctions.jl.git): 
  * Users have to take into account the following syntax change: `@yield return arg` is replaced by `@yield arg`.
* v0.4 (2017) only supports Julia v0.6 and above. It is a complete rewrite: more julian and less pythonic. The discrete event features are on par with v0.3 (SimPy v3) and following features are added:
  * Scheduling of events can be done with `Base.Dates.Datetime` and `Base.Dates.Period`
  * Two ways of making `Processes` are provided:
    - using the existing concept of `Tasks`
    - using a novel finite-statemachine approach
  * A continuous time solver based on the standalone [QSS](https://sourceforge.net/projects/qssengine/) solver is implemented. Only non-stiff systems can be solved efficiently.
* v0.3 (2015) synchronizes the API with SimPy v3 and is Julia v0.3, v0.4 and v0.5 compatible:
  * Documentation is available at [readthedocs](http://simjuliajl.readthedocs.org/en/latest/).
  * The continuous time solver is not implemented.
* v0.2 (2014) introduces a continuous time solver inspired by the Simula library [DISCO](http://www.akira.ruc.dk/~keld/research/DISCO/) and is Julia v0.2 and v0.3 compatible.
* v0.1 (2013) is a Julia clone of SimPy v2 and is Julia v0.2 compatible.

## Todo

* Transparent statistics gathering for resources.
* Update of documentation.

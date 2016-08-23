SimJulia
========

**SimJulia** is a combined continuous time / discrete event process oriented simulation framework written in [Julia](http://julialang.org/) inspired by the Simula library [DISCO](http://www.akira.ruc.dk/~keld/research/DISCO/) and the Python library [SimPy](https://simpy.readthedocs.io/).

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


#### Documentation

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://BenLauwens.github.io/SimJulia.jl/stable)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://BenLauwens.github.io/SimJulia.jl/latest)


#### Release Notes

* Version 0.4 is a complete rewrite: more julian and less pythonic.
* Scheduling is based on TimeType and Period.
* The discrete event features are on par with version 0.3. (STABLE)
* The continuous time simulation is based on a quantized state system solver. (EXPERIMENTAL)
* Documentation is automated with [Documenter.jl](https://github.com/JuliaDocs/Documenter.jl).


#### Todo

* Integration of stiff ODE
* Extension to PDE by method of lines Integration


#### Authors

* Ben Lauwens, Royal Military Academy, Brussels, Belgium


#### License

[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](LICENSE.md)

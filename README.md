SimJulia
========

[![Build Status](https://travis-ci.org/BenLauwens/SimJulia.jl.svg?branch=continuous)](https://travis-ci.org/BenLauwens/SimJulia.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/djuiegytv44pr54c?svg=true)](https://ci.appveyor.com/project/BenLauwens/simjulia-jl)

[![Coverage Status](https://coveralls.io/repos/BenLauwens/SimJulia.jl/badge.svg?branch=continous)](https://coveralls.io/r/BenLauwens/SimJulia.jl?branch=master)
[![codecov.io](http://codecov.io/github/BenLauwens/SimJulia.jl/coverage.svg?branch=continuous)](http://codecov.io/github/BenLauwens/SimJulia.jl?branch=master)

[![SimJulia](http://pkg.julialang.org/badges/SimJulia_0.3.svg)](http://pkg.julialang.org/?pkg=SimJulia&ver=0.3)
[![SimJulia](http://pkg.julialang.org/badges/SimJulia_0.4.svg)](http://pkg.julialang.org/?pkg=SimJulia&ver=0.4)

[![Documentation Status](https://readthedocs.org/projects/simjuliajl/badge/?version=latest)](https://readthedocs.org/projects/simjuliajl/?badge=latest)

[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](LICENSE.md)

**SimJulia** is a combined continuous time / discrete event process oriented simulation framework written in [Julia](http://julialang.org/) inspired by the Simula library [DISCO](w.akira.ruc.dk/~keld/research/DISCO/) and the Python library [SimPy](http://simpy.sourceforge.net/).

**Note:** for the moment the continuous time part is not operational. A *quantized state system* (QSS) solver is being developed for continuous system simulation. Users that need this feature can use the version 2.1 with the old SimPy API and a suboptimal Runge-Kutta continuous time integrator.

#### Release Notes
* Version 0.4 introduces the continuous time simulation.
* The API for continuous time simulation is inspired by DISCO.
* Julia v0.4 and v0.5 compatible.
* Documentation included
  * All combined continuous time/discrete event examples of DISCO are implemented.
  * 10 min tutorial and topical guides are updated.
  * API is also completed.

* Version 0.3 synchronizes the API with SimPy v3.
* It is a complete rewrite allowing a more powerful and unified discrete event approach.
* Julia v0.3 and v0.4 compatible.
* Documentation included:
  * All examples of the SimPy distribution are implemented.
  * 10 min tutorial is included to give users a taste of discrete event simulation with SimJulia.
  * Topical guides detail all functions.
  * API is up-to-date.

#### ToDo

* Reintroduce the *Monitor* feature of the 0.2 version.
* Develop a software layer to automate the MonteCarlo approach. 

#### Documentation

<http://simjuliajl.readthedocs.org/en/latest/welcome.html>

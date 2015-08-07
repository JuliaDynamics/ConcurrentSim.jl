SimJulia
========

[![Build Status](https://travis-ci.org/BenLauwens/SimJulia.jl.svg?branch=master)](https://travis-ci.org/BenLauwens/SimJulia.jl)
[![Coverage Status](https://coveralls.io/repos/BenLauwens/SimJulia.jl/badge.svg?branch=master)](https://coveralls.io/r/BenLauwens/SimJulia.jl?branch=master)
[![SimJulia](http://pkg.julialang.org/badges/SimJulia_release.svg)](http://pkg.julialang.org/?pkg=SimJulia&ver=release)
[![SimJulia](http://pkg.julialang.org/badges/SimJulia_nightly.svg)](http://pkg.julialang.org/?pkg=SimJulia&ver=nightly)
[![Documentation Status](https://readthedocs.org/projects/simjuliajl/badge/?version=latest)](https://readthedocs.org/projects/simjuliajl/?badge=latest)

**SimJulia** is a combined continuous time / discrete event process oriented simulation framework written in [Julia](http://julialang.org) inspired by the Simula library **DISCO** and the Python library [SimPy](http://simpy.sourceforge.net/).

**Note:** for the moment the continuous time part is not operational. A *quantized state system* (QSS) solver is being developed for continuous system simulation. Users that need this feature can use the version 2.1 with the old SimPy API and a suboptimal Runge-Kutta continuous time integrator.

#### Release Notes

* Version 0.3 synchronizes the API with SimPy.
* It is a complete rewrite allowing a more powerful and unified discrete event approach.
* All examples of the SimPy distribution are implemented.

#### ToDo

* Add the documentation.
* Integrate the to be written QSS solver.
* Reintroduce the *Monitor* feature of the 0.2 version.

#### Documentation

<http://simjuliajl.readthedocs.org/en/latest/welcome.html>

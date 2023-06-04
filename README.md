# ConcurrentSim (formerly SimJulia)

<table>
    <tr>
        <td>Documentation</td>
        <td>
            <a href="https://juliadynamics.github.io/ConcurrentSim.jl/stable"><img src="https://img.shields.io/badge/docs-stable-blue.svg" alt="Documentation of latest stable version"></a>
            <a href="https://juliadynamics.github.io/ConcurrentSim.jl/dev"><img src="https://img.shields.io/badge/docs-dev-blue.svg" alt="Documentation of dev version"></a>
        </td>
    </tr><tr></tr>
    <tr>
        <td>Continuous integration</td>
        <td>
            <a href="https://github.com/JuliaDynamics/ConcurrentSim.jl/actions?query=workflow%3ACI+branch%3Amaster"><img src="https://img.shields.io/github/actions/workflow/status/JuliaDynamics/ConcurrentSim.jl/ci.yml?branch=master" alt="GitHub Workflow Status"></a>
        </td>
    </tr><tr></tr>
    <tr>
        <td>Code coverage</td>
        <td>
            <a href="https://codecov.io/gh/JuliaDynamics/ConcurrentSim.jl"><img src="https://img.shields.io/codecov/c/gh/JuliaDynamics/ConcurrentSim.jl?label=codecov" alt="Test coverage from codecov"></a>
        </td>
    </tr><tr></tr>
    <tr>
        <td>Static analysis with</td>
        <td>
            <a href="https://github.com/aviatesk/JET.jl"><img src="https://img.shields.io/badge/JET.jl-%E2%9C%88%EF%B8%8F-9cf" alt="JET static analysis"></a>
            <a href="https://github.com/JuliaTesting/Aqua.jl"><img src="https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg" alt="Aqua QA"></a>
        </td>
    </tr>
</table>

A discrete event process oriented simulation framework written in [Julia](http://julialang.org/) inspired by the Python library [SimPy](https://simpy.readthedocs.io/). One of the longest-lived Julia packages (originally under the name SimJulia).

## Installation

ConcurrentSim.jl is a [registered package](http://pkg.julialang.org), and is installed by running

```julia
julia> Pkg.add("ConcurrentSim")
```

## License

[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](LICENSE.md)

## Authors

* Ben Lauwens, Royal Military Academy, Brussels, Belgium.
* Maintainer volunteers from the JuliaDynamics and QuantumSavory organizations.

## Contributing

* To discuss problems or feature requests, file an issue. For bugs, please include as much information as possible, including operating system, julia version, and version of the dependencies: `DataStructures` and `ResumableFunctions`.
* To contribute, make a pull request. Contributions should include tests for any new features/bug fixes.

## Release Notes

A [detailed change log is kept](https://github.com/JuliaDynamics/ConcurrentSim.jl/blob/master/CHANGELOG.md).

## Alternatives

`ConcurrentSim.jl` and `DiscreteEvents.jl` both provide for typical event-based simulations. `ConcurrentSim.jl` is built around coroutines (implemented in `ResumableFunctions.jl`), while `DiscreteEvents.jl` uses Julia's async primitives via `Channels`. If you are evaluating which library to you for your goals, `ConcurrentSim.jl` might be a good choice if you are used to python's SimPy, but otherwise you are advised to try a small demo project in each and do your own benchmarks. Do not hesitate to submit issues on Github with questions or suggestions or feature requests. We value hearing what your experience with this library (compared to other libraries) has been.

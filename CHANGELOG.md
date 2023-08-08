# News

## v1.4.0 - 2023-08-07

- Implement a `DelayQueue`, i.e. a `QueueStore` with latency between the store and take events.
- Bugfix to `QueueStore` and `StackStore` for take events on empty stores.

## v1.3.0 - 2023-08-07

- Implement ordered versions of `Store`, namely `QueueStore` and `StackStore`.

## v1.2.0 - 2023-08-06

- Priorities can now be non-integer.
- Relax some of the previous deprecations, implement `Base.lock` and `Base.trylock`, and document the differences in blocking and yield-ness of Base and ConcurrentSim methods.

## v1.1.0 - 2023-08-02

- Start using `Base`'s API: `Base.unlock`, `Base.islocked`, `Base.isready`, `Base.put!`, `Base.take!`. Deprecate `put`, `release`. Moreover, consider using `Base.take!` instead of `Base.get` (which was not deprecated yet, as we decide which semantics to follow). Lastly, `Base.lock` and `Base.trylock` are **not** implement -- they are superficially similar to `request` and `tryrequest`, but have to be explicitly `@yield`-ed.
- Implement `tryrequest` (similar to `Base.trylock`). However, consider also using `Base.isready` and `request` instead of `tryrequest`.

## v1.0.0 - 2023-05-03

- Rename from SimJulia.jl to ConcurrentSim.jl

## Changelog of SimJulia.jl before the renaming

* v0.8.2 (2021)
  * implementation of Store based on a Dict
* v0.8.1 (2021)
  * some minor bug fixes
  * uses ResumableFunctions v0.6 or higher 
* v0.8 (2019)
  * adds support for Julia v1.2.
* v0.7 (2018)
  * adds support for Julia v1.0
* v0.6 (2018)
  * adds support for Julia v0.7.
  * the `@oldprocess` macro and the `produce` / `consume` functions are removed because they are no longer supported.
* v0.5 (2018)
  * The old way of making processes is deprecated in favor of the semi-coroutine approach as implemented in [ResumableFunctions](https://github.com/BenLauwens/ResumableFunctions.jl.git). The `@process` macro replaces the `@coroutine` macro. The old `@process` macro is temporarily renamed `@oldprocess` and will be removed when the infrastructure supporting the `produce` and the `consume` functions is no longer available in Julia. (DONE)
  * This version no longer integrates a continuous time solver. A continuous simulation framework based on [DISCO](http://www.akira.ruc.dk/~keld/research/DISCO/) and inspired by the standalone [QSS](https://sourceforge.net/projects/qssengine/) solver using ConcurrentSim as its discrete-event engine can be found in the repository [QuantizedStateSystems](https://github.com/BenLauwens/QuantizedStateSystems.jl.git) (WIP):
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

using Documenter
using ConcurrentSim

DocMeta.setdocmeta!(ConcurrentSim, :DocTestSetup, :(using ConcurrentSim, ResumableFunctions); recursive=true)
doctest(ConcurrentSim)

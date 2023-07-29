using Revise
using Documenter
using ResumableFunctions
using ConcurrentSim

DocMeta.setdocmeta!(ConcurrentSim, :DocTestSetup, :(using ConcurrentSim, ResumableFunctions); recursive=true)

makedocs(
  sitename = "ConcurrentSim",
  authors = "Ben Lauwens and SimJulia & ConcurrentSim contributors",
  strict = true,
  doctest = false,
  pages    = [
    "Home" => "index.md",
    "Tutorial" => "tutorial.md",
    "Topical Guides" => ["Basics" => "guides/basics.md",
                         "Environments" => "guides/environments.md",
                         "Events" => "guides/events.md",],
    "Examples" => ["Ross" => "examples/ross.md", "Latency" =>
                   "examples/Latency.md"],
    "API" => "api.md"
  ]
)

deploydocs(
  repo = "github.com/JuliaDynamics/ConcurrentSim.jl.git"
)

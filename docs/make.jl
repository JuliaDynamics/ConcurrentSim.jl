using Revise
using Documenter
using ResumableFunctions
using ConcurrentSim

DocMeta.setdocmeta!(ConcurrentSim, :DocTestSetup, :(using ConcurrentSim, ResumableFunctions); recursive=true)

makedocs(
  sitename = "ConcurrentSim",
  authors = "Ben Lauwens and SimJulia & ConcurrentSim contributors",
  doctest = false,
  pages    = [
    "Home" => "index.md",
    "Tutorial" => "tutorial.md",
    "Topical Guides" => [
        "Basics" => "guides/basics.md",
        "Environments" => "guides/environments.md",
        "Events" => "guides/events.md",
        "Resource API" => "guides/blockingandyielding.md",
        ],
    "Examples" => [
        "Ross" => "examples/ross.md",
        "Latency" => "examples/Latency.md",
        "Multi-server Queue" => "examples/mmc.md",
    ],
    "API" => "api.md"
  ]
)

deploydocs(
  repo = "github.com/JuliaDynamics/ConcurrentSim.jl.git"
)

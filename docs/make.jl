using Documenter
using Semicoroutines
using ConcurrentSim

makedocs(
  sitename = "ConcurrentSim",
  authors = "ConcurrentSim contributors",
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
  repo = "github.com/QuantumSavory/ConcurrentSim.jl.git"
)

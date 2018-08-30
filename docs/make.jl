using Documenter
using ResumableFunctions
using SimJulia

makedocs(
  format   = :html,
  sitename = "SimJulia",
  authors = "Ben Lauwens",
  pages    = [
    "Home" => "index.md",
    "Tutorial" => "tutorial.md",
    "Topical Guides" => ["Basics" => "guides/basics.md",
                         "Environments" => "guides/environments.md",
                         "Events" => "guides/events.md",],
    "Examples" => ["Ross" => "examples/ross.md",],
    "API" => "api.md"
  ]
)

deploydocs(
  repo = "github.com/BenLauwens/SimJulia.jl.git",
  julia  = "1.0",
  osname = "linux",
  target = "build",
  deps = nothing,
  make = nothing,
)

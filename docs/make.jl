using Documenter
using SimJulia

makedocs(
  modules = [SimJulia],
  clean   = true,
  format   = Documenter.Formats.HTML,
  sitename = "SimJulia.jl",
  pages    = [
    "Home" => "index.md",
    "Intro" => [
      "10_min/installation.md",
    ],
    "Manual" => "topics.md",
    "Library" => "api.md"
    ]

)

deploydocs(
  repo = "github.com/BenLauwens/SimJulia.jl.git",
  julia  = "0.5",
  osname = "linux",
  target = "build",
  deps = nothing,
  make = nothing,
)

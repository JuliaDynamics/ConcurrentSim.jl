using Documenter
using SimJulia

makedocs(
  modules = [SimJulia],
  clean   = true,
  format   = :html,
  sitename = "SimJulia.jl",
  pages    = [
    "Home" => "index.md",
    "Intro" => [
      "10_min/1_installation.md",
      "10_min/2_basic_concepts.md",
      "10_min/3_process_interaction.md",
    ],
    "Manual" => "topics.md",
    "Examples" => [
      "examples/1_bank_renege.md",
    ],
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

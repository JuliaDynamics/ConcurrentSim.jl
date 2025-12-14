using Revise
using Documenter
using AnythingLLMDocs
using ResumableFunctions
using ConcurrentSim

DocMeta.setdocmeta!(ConcurrentSim, :DocTestSetup, :(using ConcurrentSim, ResumableFunctions); recursive=true)

doc_modules = [ConcurrentSim]

api_base="https://anythingllm.krastanov.org/api/v1"
anythingllm_assets = integrate_anythingllm(
  "ConcurrentSim",
  doc_modules,
  @__DIR__,
  api_base;
  repo = "github.com/JuliaDynamics/ConcurrentSim.jl.git",
  options = EmbedOptions(),
)

makedocs(
  sitename = "ConcurrentSim",
  authors = "Ben Lauwens and SimJulia & ConcurrentSim contributors",
  doctest = false,
  format = Documenter.HTML(assets = anythingllm_assets),
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

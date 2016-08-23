using Documenter
using SimJulia

makedocs(
  modules = [SimJulia]
)

deploydocs(
  deps   = Deps.pip("pygments", "mkdocs", "mkdocs-cinder", "python-markdown-math"),
  repo = "github.com/BenLauwens/SimJulia.jl.git",
  julia  = "0.5",
  osname = "linux"
)

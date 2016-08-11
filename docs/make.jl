using Documenter
using SimJulia

makedocs()

deploydocs(
    deps   = Deps.pip("mkdocs", "python-markdown-math"),
    repo = "github.com/BenLauwens/SimJulia.jl.git",
    julia  = "0.5",
    osname = "linux"
)

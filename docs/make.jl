using DataGraphs
using Documenter

DocMeta.setdocmeta!(DataGraphs, :DocTestSetup, :(using DataGraphs); recursive=true)

makedocs(;
  modules=[DataGraphs],
  authors="Matthew Fishman <mfishman@flatironinstitute.org> and contributors",
  repo="https://github.com/mtfishman/DataGraphs.jl/blob/{commit}{path}#{line}",
  sitename="DataGraphs.jl",
  format=Documenter.HTML(;
    prettyurls=get(ENV, "CI", "false") == "true",
    canonical="https://mtfishman.github.io/DataGraphs.jl",
    assets=String[],
  ),
  pages=["Home" => "index.md"],
)

deploydocs(; repo="github.com/mtfishman/DataGraphs.jl", devbranch="main")

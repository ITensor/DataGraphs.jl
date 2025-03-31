using DataGraphs: DataGraphs
using Documenter: Documenter, DocMeta, deploydocs, makedocs

DocMeta.setdocmeta!(
  DataGraphs, :DocTestSetup, :(using DataGraphs); recursive=true
)

include("make_index.jl")

makedocs(;
  modules=[DataGraphs],
  authors="ITensor developers <support@itensor.org> and contributors",
  sitename="DataGraphs.jl",
  format=Documenter.HTML(;
    canonical="https://itensor.github.io/DataGraphs.jl",
    edit_link="main",
    assets=["assets/favicon.ico", "assets/extras.css"],
  ),
  pages=["Home" => "index.md", "Reference" => "reference.md"],
)

deploydocs(;
  repo="github.com/ITensor/DataGraphs.jl", devbranch="main", push_preview=true
)

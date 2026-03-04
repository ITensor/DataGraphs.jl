using DataGraphs: DataGraphs
using Documenter: Documenter, DocMeta, deploydocs, makedocs
using ITensorFormatter: ITensorFormatter

DocMeta.setdocmeta!(DataGraphs, :DocTestSetup, :(using DataGraphs); recursive = true)

ITensorFormatter.make_index!(pkgdir(DataGraphs))

makedocs(;
    modules = [DataGraphs],
    authors = "ITensor developers <support@itensor.org> and contributors",
    sitename = "DataGraphs.jl",
    format = Documenter.HTML(;
        canonical = "https://itensor.github.io/DataGraphs.jl",
        edit_link = "main",
        assets = ["assets/favicon.ico", "assets/extras.css"]
    ),
    pages = ["Home" => "index.md", "Reference" => "reference.md"]
)

deploydocs(;
    repo = "github.com/ITensor/DataGraphs.jl",
    devbranch = "main",
    push_preview = true
)

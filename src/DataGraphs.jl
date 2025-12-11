module DataGraphs

include("utils.jl")
include("traits/isunderlyinggraph.jl")
include("dataview.jl")
include("abstractdatagraph.jl")
include("indexing.jl")
include("datagraph.jl")

export AbstractDataGraph, DataGraph

end

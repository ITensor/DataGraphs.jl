module DataGraphs

include("utils.jl")
include("traits/isunderlyinggraph.jl")
include("dataview.jl")
include("abstractdatagraph.jl")
include("datagraph.jl")
# TODO: Turn into an extension once `PartitionedGraphs` is excised.
include("lib/DataGraphsPartitionedGraphsExt/src/DataGraphsPartitionedGraphsExt.jl")

export AbstractDataGraph, DataGraph

end

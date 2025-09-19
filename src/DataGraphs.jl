module DataGraphs

include("utils.jl")
include("traits/isunderlyinggraph.jl")
include("abstractdatagraph.jl")
include("datagraph.jl")
# TODO: Turn into a weak dependency once `GraphsExtensions`
# is split off from `NamedGraphs`.
include("../ext/DataGraphsNamedGraphsExt/DataGraphsNamedGraphsExt.jl")

export AbstractDataGraph, DataGraph

end

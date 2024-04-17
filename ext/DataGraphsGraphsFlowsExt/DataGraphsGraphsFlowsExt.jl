module DataGraphsGraphsFlowsExt
using DataGraphs: AbstractDataGraph, underlying_graph
using GraphsFlows: GraphsFlows

function GraphsFlows.mincut(graph::AbstractDataGraph, args...; kwargs...)
  return GraphsFlows.mincut(underlying_graph(graph), args...; kwargs...)
end
end

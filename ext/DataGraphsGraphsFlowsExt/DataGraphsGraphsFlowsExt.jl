module DataGraphsGraphsFlowsExt
using DataGraphs: AbstractDataGraph, underlying_graph
using GraphsFlows: GraphsFlows

function GraphsFlows.mincut(
        graph::AbstractDataGraph,
        source_vertex,
        target_vertex;
        kwargs...
    )
    return GraphsFlows.mincut(
        underlying_graph(graph),
        source_vertex,
        target_vertex;
        kwargs...
    )
end

end

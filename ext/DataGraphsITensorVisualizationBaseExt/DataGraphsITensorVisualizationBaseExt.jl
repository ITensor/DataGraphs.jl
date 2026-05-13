module DataGraphsITensorVisualizationBaseExt

using DataGraphs: AbstractDataGraph, underlying_graph
using ITensorVisualizationBase: ITensorVisualizationBase

function ITensorVisualizationBase.visualize(graph::AbstractDataGraph, args...; kwargs...)
    return ITensorVisualizationBase.visualize(
        underlying_graph(graph), args...; kwargs...
    )
end

end

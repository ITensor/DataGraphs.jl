module DataGraphsNamedGraphsExt
using DataGraphs: DataGraphs, AbstractDataGraph, underlying_graph
using NamedGraphs: NamedGraphs, AbstractNamedGraph

DataGraphs.is_underlying_graph(::Type{<:AbstractNamedGraph}) = true

for f in [:(NamedGraphs.position_graph), :(NamedGraphs.vertex_positions)]
    @eval begin
        function $f(graph::AbstractDataGraph)
            return $f(underlying_graph(graph))
        end
    end
end

using Graphs: edgetype, vertices
using NamedGraphs.OrdinalIndexing: OrdinalSuffixedInteger
# TODO: Define through some intermediate `to_vertex` function
# (analagous to Julia's `to_indices`) instead of through
# overloading `Base.getindex`.
function Base.getindex(graph::AbstractDataGraph, vertex::OrdinalSuffixedInteger)
    return graph[vertices(graph)[vertex]]
end
function Base.getindex(
        graph::AbstractDataGraph, edge::Pair{<:OrdinalSuffixedInteger, <:OrdinalSuffixedInteger}
    )
    return graph[edgetype(graph)(vertices(graph)[edge[1]], vertices(graph)[edge[2]])]
end
function Base.setindex!(graph::AbstractDataGraph, value, vertex::OrdinalSuffixedInteger)
    graph[vertices(graph)[vertex]] = value
    return graph
end
function Base.setindex!(
        graph::AbstractDataGraph,
        value,
        edge::Pair{<:OrdinalSuffixedInteger, <:OrdinalSuffixedInteger},
    )
    graph[edgetype(graph)(vertices(graph)[edge[1]], vertices(graph)[edge[2]])] = value
    return graph
end
end

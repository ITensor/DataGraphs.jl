using NamedGraphs: to_graph_index, AbstractEdges, AbstractVertices
using NamedGraphs.GraphsExtensions: subgraph, edge_subgraph

function Base.getindex(graph::AbstractDataGraph, indices)
    return _getindex(graph, to_graph_index(graph, indices))
end

_getindex(graph::AbstractGraph, vertex) = get_vertex_data(graph, vertex)

function _getindex(graph::AbstractGraph, edge::AbstractEdge)
    data = get_edge_data(graph, arrange_edge(graph, edge))
    return reverse_data_direction(graph, edge, data)
end

function _getindex(graph::AbstractGraph, vertices::AbstractVertices)
    return subgraph(graph, vertices)
end
function _getindex(graph::AbstractGraph, edges::AbstractEdges)
    return edge_subgraph(graph, edges)
end

# Support syntax `g[1, 2] = g[(1, 2)]`
function Base.getindex(graph::AbstractDataGraph, i1, i2, i...)
    return graph[(i1, i2, i...)]
end

function Base.setindex!(graph::AbstractDataGraph, data, index)
    _setindex!(graph, data, to_graph_index(graph, index))
    return graph
end

function _setindex!(graph::AbstractGraph, data, vertex)
    set_vertex_data!(graph, data, vertex)
    return graph
end

function _setindex!(graph::AbstractGraph, data, edge::AbstractEdge)
    arranged_edge = arrange_edge(graph, edge)
    arranged_data = reverse_data_direction(graph, edge, data)
    set_edge_data!(graph, arranged_data, arranged_edge)
    return graph
end

function _setindex!(graph::AbstractGraph, val, vertices::AbstractVertices)
    return set_vertices_data!(graph, val, vertices)
end
function _setindex!(graph::AbstractGraph, val, edges::AbstractEdges)
    return set_edges_data!(graph, val, edges)
end

# Support syntax `g[1, 2] = g[(1, 2)]`
function Base.setindex!(graph::AbstractDataGraph, x, i1, i2, i...)
    graph[(i1, i2, i...)] = x
    return graph
end

# Ordinal Indexing

function NamedGraphs.to_graph_index(
        graph::AbstractGraph,
        pair::Pair{<:OrdinalSuffixedInteger, <:OrdinalSuffixedInteger}
    )
    vs = vertices(graph)
    v1, v2 = pair
    return to_graph_index(graph, vs[v1] => vs[v2])
end
function NamedGraphs.to_graph_index(graph::AbstractGraph, vertex::OrdinalSuffixedInteger)
    return to_graph_index(graph, vertices(graph)[vertex])
end

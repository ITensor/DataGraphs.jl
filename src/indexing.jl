using NamedGraphs:
    to_graph_index,
    AbstractEdges,
    AbstractVertices,
    to_vertices,
    to_edges,
    AbstractGraphIndices
using NamedGraphs.GraphsExtensions: subgraph
using Dictionaries: AbstractIndices, getindices

# ====================================== getindex ======================================= #

NamedGraphs.get_graph_index(graph::AbstractDataGraph, index) = get_index_data(graph, index)
# If unknown, treat like  single vertex
get_index_data(graph::AbstractGraph, vertex) = _get_index_data(graph, vertex)

# _get_index_data exists to avoid method ambiguity when overloading get_index_data
function _get_index_data(graph::AbstractGraph, vertex)
    isassigned(graph, vertex) || throw(IndexError("Vertex $vertex not assigned"))
    return get_vertex_data(graph, vertex)
end
function _get_index_data(graph::AbstractGraph, edge::AbstractEdge)
    isassigned(graph, edge) || throw(IndexError("Edge $edge not assigned"))
    data = get_edge_data(graph, arrange_edge(graph, edge))
    return reverse_data_direction(graph, edge, data)
end

# ====================================== isassigned ====================================== #

function Base.isassigned(graph::AbstractDataGraph, index)
    return isassigned_datagraph(graph, to_graph_index(graph, index))
end

isassigned_datagraph(graph::AbstractGraph, ind) = is_graph_index_assigned(graph, ind)
isassigned_datagraph(graph::AbstractGraph, inds::AbstractGraphIndices) = all(ind -> isassigned(graph, ind), inds)

is_graph_index_assigned(graph::AbstractGraph, vertex) = is_vertex_assigned(graph, vertex)

function is_graph_index_assigned(graph::AbstractGraph, edge::AbstractEdge)
    return is_edge_assigned(graph, arrange_edge(graph, edge))
end

# ====================================== setindex! ======================================= #

function Base.setindex!(graph::AbstractDataGraph, data, index)
    setindex!_datagraph(graph, data, to_graph_index(graph, index))
    return graph
end

function setindex!_datagraph(graph::AbstractGraph, data, vertex)
    set_index_data!(graph, data, vertex)
    return graph
end

function setindex!_datagraph(graph::AbstractGraph, data, edge::AbstractEdge)
    arranged_edge = arrange_edge(graph, edge)
    arranged_data = reverse_data_direction(graph, edge, data)
    set_index_data!(graph, arranged_data, arranged_edge)
    return graph
end

function setindex!_datagraph(graph::AbstractGraph, val, vertices::AbstractVertices)
    return set_indices_data!(graph, val, vertices)
end
function setindex!_datagraph(graph::AbstractGraph, val, edges::AbstractEdges)
    return set_indices_data!(graph, val, edges)
end

function set_index_data!(g::AbstractGraph, val, vertex)
    if !has_vertex(g, vertex)
        add_vertex!(g, vertex)
    end
    set_vertex_data!(g, val, vertex)
    return g
end
function set_index_data!(g::AbstractGraph, val, edge::AbstractEdge)
    if !has_edge(g, edge)
        add_edge!(g, edge)
    end
    set_edge_data!(g, val, edge)
    return g
end

function set_indices_data!(g::AbstractGraph, val, vertices::AbstractVertices)
    set_vertices_data!(g, val, vertices)
    return g
end
function set_indices_data!(g::AbstractGraph, val, edges::AbstractEdges)
    set_edges_data!(g, val, edges)
    return g
end
function set_vertices_data!(g::AbstractGraph, val, vertices)
    for v in vertices
        g[v] = val[v]
    end
    return g
end
function set_edges_data!(g::AbstractGraph, val, edges)
    for e in edges
        g[e] = val[e]
    end
    return g
end

# ======================================== Other ========================================= #

# Support syntax `g[1, 2] = g[(1, 2)]`
function Base.getindex(graph::AbstractDataGraph, i1, i2, i...)
    return graph[(i1, i2, i...)]
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

# ====================================== getindices ====================================== #

Dictionaries.getindices(graph::AbstractDataGraph, inds::Indices) = map(ind -> graph[ind], inds)

# ========================================= view ========================================= #

Base.view(graph::AbstractDataGraph, inds::Indices) = view(vertex_data(graph), inds)
Base.view(graph::AbstractDataGraph, inds::Indices{<:Pair}) = view(edge_data(graph), inds)
Base.view(graph::AbstractDataGraph, inds::Indices{<:AbstractEdge}) = view(edge_data(graph), inds)

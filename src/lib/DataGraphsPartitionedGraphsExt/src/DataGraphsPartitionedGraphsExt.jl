module DataGraphsPartitionedGraphsExt
using Graphs: Graphs, AbstractGraph, AbstractEdge, vertices, edges
using ..DataGraphs:
    AbstractDataGraph,
    DataGraphs,
    edge_data,
    underlying_graph,
    vertex_data,
    get_vertex_data,
    get_edge_data,
    set_vertex_data!,
    set_edge_data!,
    has_vertex_data,
    has_edge_data,
    has_vertices_data,
    has_edges_data,
    unset_vertex_data!,
    unset_edge_data!,
    unset_vertices_data!,
    unset_edges_data!,
    vertices_data_eltype,
    edges_data_eltype
using NamedGraphs: to_graph_indices
using NamedGraphs.PartitionedGraphs:
    PartitionedGraphs,
    QuotientEdge,
    QuotientEdgeEdges,
    QuotientVertex,
    QuotientVertexVertices,
    QuotientView,
    partitioned_vertices,
    quotientvertices,
    quotientedges,
    parent_graph_type,
    quotient_index
using Dictionaries: Dictionary, Indices

# Methods to overload if you dont want to use the defaults.
# DataGraphs.has_vertices_data(g::MyGraph, v::QuotientVertexVertices)
# DataGraphs.has_edges_data(g::MyGraph, v::QuotientEdgeEdges)
#
# DataGraphs.get_vertices_data(g::MyGraph, v::QuotientVertexVertices)
# DataGraphs.get_edges_data(g::MyGraph, v::QuotientEdgeEdges)
#
# DataGraphs.set_vertices_data!(g::MyGraph, v::QuotientVertexVertices)
# DataGraphs.set_edges_data!(g::MyGraph, v::QuotientEdgeEdges)
#
# DataGraphs.unset_vertices_data!(g::MyGraph, v::QuotientVertexVertices)
# DataGraphs.unset_edges_data!(g::MyGraph, v::QuotientEdgeEdges)
#
# DataGraphs.vertices_data_eltype(::Type{<:MyGraph}, ::Type{<:QuotientVertexVertices})
# DataGraphs.edges_data_eltype(::Type{<:MyGraph}, ::Type{<:QuotientVertexVertices})

PartitionedGraphs.quotient_index(vertex) = QuotientVertex(vertex)
PartitionedGraphs.quotient_index(edge::AbstractEdge) = QuotientEdge(edge)

# QuotientView; make sure quotient views of data graphs do data graph indexing.
function Base.getindex(qv::QuotientView{V, <:AbstractDataGraph}, ind) where {V}
    return getindex(parent(qv), quotient_index(to_graph_indices(qv, ind)))
end

function Base.setindex!(qv::QuotientView{V, <:AbstractDataGraph}, val, ind) where {V}
    return setindex!(parent(qv), val, quotient_index(to_graph_indices(qv, ind)))
end

function DataGraphs.get_vertex_data(qv::QuotientView, v)
    return getindex(parent(qv), QuotientVertex(v))
end
function DataGraphs.get_edge_data(qv::QuotientView, e)
    return getindex(parent(qv), QuotientEdge(e))
end

function DataGraphs.set_vertex_data!(qv::QuotientView, val, v)
    return setindex!(parent(qv), val, QuotientVertex(v))
end
function DataGraphs.set_edge_data!(qv::QuotientView, val, e)
    return setindex!(parent(qv), val, QuotientEdge(e))
end

function DataGraphs.has_vertex_data(qv::QuotientView, v)
    pg = parent(qv)
    return has_vertices_data(pg, to_graph_indices(pg, QuotientVertex(v)))
end
function DataGraphs.has_edge_data(qv::QuotientView, e)
    pg = parent(qv)
    return has_edges_data(pg, to_graph_indices(pg, QuotientEdge(e)))
end

function DataGraphs.unset_vertex_data!(qv::QuotientView, v)
    pg = parent(qv)
    return unset_vertices_data!(pg, to_graph_indices(pg, QuotientVertex(v)))
end
function DataGraphs.unset_edge_data!(qv::QuotientView, e)
    pg = parent(qv)
    return unset_edges_data!(pg, to_graph_indices(pg, QuotientEdge(e)))
end

function DataGraphs.vertex_data_eltype(T::Type{<:QuotientView})
    return vertices_data_eltype(parent_graph_type(T), QuotientVertexVertices)
end
function DataGraphs.edge_data_eltype(T::Type{<:QuotientView})
    return edges_data_eltype(parent_graph_type(T), QuotientEdgeEdges)
end

DataGraphs.underlying_graph(qv::QuotientView) = underlying_graph(copy(qv))

function Base.isassigned(qv::QuotientView, ind)
    return isassigned(parent(qv), quotient_index(to_graph_indices(qv, ind)))
end

# PartitionedGraphs interface
function PartitionedGraphs.partitioned_vertices(dg::AbstractDataGraph)
    return partitioned_vertices(underlying_graph(dg))
end

PartitionedGraphs.partitionedgraph(::AbstractDataGraph, parts) = not_implemented()
PartitionedGraphs.departition(::AbstractDataGraph) = not_implemented()

function DataGraphs.vertices_data_eltype(
        T::Type{<:AbstractGraph},
        ::Type{<:QuotientVertexVertices}
    )
    return eltype(Base.promote_op(quotientvertices_data, T))
end

function quotientvertices_data(g::AbstractGraph)
    qvs = PartitionedGraphs.quotientvertices(g)
    data = map(qv -> DataGraphs.get_vertices_data(g, to_graph_indices(g, qv)), qvs)
    return data
end

function DataGraphs.edges_data_eltype(
        T::Type{<:AbstractGraph},
        ::Type{<:QuotientEdgeEdges}
    )
    return eltype(Base.promote_op(quotientedges_data, T))
end

function quotientedges_data(g::AbstractGraph)
    qes = PartitionedGraphs.quotientedges(g)
    data = map(qe -> DataGraphs.get_edges_data(g, to_graph_indices(g, qe)), qes)
    return data
end

end

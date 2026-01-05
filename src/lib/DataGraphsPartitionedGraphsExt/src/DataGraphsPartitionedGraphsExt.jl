module DataGraphsPartitionedGraphsExt
using NamedGraphs.PartitionedGraphs: quotient_graph_vertextype
using Graphs: Graphs, AbstractGraph, AbstractEdge, vertices, edges
using ..DataGraphs:
    _getindex,
    AbstractDataGraph,
    DataGraphs,
    edge_data,
    edgetype,
    underlying_graph,
    vertex_data,
    get_vertex_data,
    get_edge_data,
    get_vertices_data,
    get_edges_data,
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
using NamedGraphs: to_graph_index, parent_graph_indices, Vertices, Edges
using NamedGraphs.GraphsExtensions: vertextype
using NamedGraphs.PartitionedGraphs:
    PartitionedGraphs,
    QuotientEdge,
    QuotientEdgeEdge,
    QuotientEdges,
    QuotientEdgeEdges,
    QuotientVertex,
    QuotientVertexVertex,
    QuotientVertexVertices,
    QuotientVerticesVertices,
    QuotientVertices,
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

# QuotientView; make sure quotient views of data graphs do data graph indexing
# and not subgraph indexing.
function Base.getindex(qv::QuotientView{V, <:AbstractDataGraph}, ind) where {V}
    return DataGraphs._getindex(qv, to_graph_index(qv, ind))
end

function Base.setindex!(qv::QuotientView{V, <:AbstractDataGraph}, val, ind) where {V}
    return DataGraphs._setindex!(qv, val, to_graph_index(qv, ind))
end

DataGraphs.get_vertex_data(qv::QuotientView, v) = getindex(parent(qv), QuotientVertex(v))
DataGraphs.get_edge_data(qv::QuotientView, e) = getindex(parent(qv), QuotientEdge(e))

function DataGraphs._get_vertices_data(g::AbstractGraph, v::QuotientVertexVertices)
    return getindex(g, Vertices(parent_graph_indices(v)))
end

function DataGraphs._get_vertices_data(g::AbstractGraph, v::QuotientVerticesVertices)
    return getindex(g, Vertices(parent_graph_indices(v)))
end

function DataGraphs._get_edges_data(g::AbstractGraph, e::QuotientEdgeEdges)
    return getindex(g, Edges(parent_graph_indices(e)))
end


# function DataGraphs.get_vertices_data(qv::QuotientView, vertices::AbstractGraphIndices)
#     inds = Indices(parent_graph_indices(vertices))
#     return map(v -> getindex(qv, v), inds)
# end

function DataGraphs.set_vertex_data!(qv::QuotientView, val, v)
    return setindex!(parent(qv), val, QuotientVertex(v))
end
function DataGraphs.set_edge_data!(qv::QuotientView, val, e)
    return setindex!(parent(qv), val, QuotientEdge(e))
end

function DataGraphs.has_vertex_data(qv::QuotientView, v)
    pg = parent(qv)
    return has_vertices_data(pg, to_graph_index(pg, QuotientVertex(v)))
end
function DataGraphs.has_edge_data(qv::QuotientView, e)
    pg = parent(qv)
    return has_edges_data(pg, to_graph_index(pg, QuotientEdge(e)))
end

function DataGraphs.unset_vertex_data!(qv::QuotientView, v)
    pg = parent(qv)
    return unset_vertices_data!(pg, to_graph_index(pg, QuotientVertex(v)))
end
function DataGraphs.unset_edge_data!(qv::QuotientView, e)
    pg = parent(qv)
    return unset_edges_data!(pg, to_graph_index(pg, QuotientEdge(e)))
end

# TODO: eltype -> type?
function DataGraphs.vertex_data_eltype(T::Type{<:QuotientView})
    PGT = parent_graph_type(T)
    return Base.promote_op(getindex, PGT, QuotientVertex{vertextype(T)})
end
function DataGraphs.edge_data_eltype(T::Type{<:QuotientView})
    PGT = parent_graph_type(T)
    return Base.promote_op(getindex, PGT, QuotientEdge{vertextype(T), edgetype(T)})
end

get_quotient_vertices_data(g::AbstractGraph) = get_vertices_data(g, QuotientVertices(g))
get_quotient_edges_data(g::AbstractGraph) = get_edges_data(g, QuotientEdges(g))

DataGraphs.underlying_graph(qv::QuotientView) = underlying_graph(copy(qv))

function Base.isassigned(qv::QuotientView, ind)
    return isassigned(parent(qv), quotient_index(to_graph_index(qv, ind)))
end

# PartitionedGraphs interface
function PartitionedGraphs.partitioned_vertices(dg::AbstractDataGraph)
    return partitioned_vertices(underlying_graph(dg))
end

PartitionedGraphs.partitionedgraph(::AbstractDataGraph, parts) = not_implemented()
PartitionedGraphs.departition(::AbstractDataGraph) = not_implemented()

function DataGraphs.vertices_data_eltype(
        T::Type{<:AbstractGraph},
        QV::Type{<:QuotientVertices}
    )
    return eltype(Base.promote_op(get_vertices_data, T, QV))
end

function DataGraphs.edges_data_eltype(
        T::Type{<:AbstractGraph},
        QE::Type{<:QuotientEdges}
    )
    return eltype(Base.promote_op(get_edges_data, T, QE))
end

end

module DataGraphsPartitionedGraphsExt
using Graphs: Graphs, AbstractGraph, AbstractEdge, vertices, edges
using ..DataGraphs:
    AbstractDataGraph,
    DataGraphs,
    edge_data,
    underlying_graph,
    vertex_data
using NamedGraphs.PartitionedGraphs:
    PartitionedGraphs,
    QuotientEdge,
    QuotientVertex,
    QuotientView,
    partitioned_vertices,
    quotientvertices,
    quotientedges
using Dictionaries: Dictionary, Indices

# Fallbacks
get_quotient_vertex_data(g::AbstractGraph, qv) = map(v -> g[v], Indices(vertices(g, qv)))
get_quotient_edge_data(g::AbstractGraph, qe) = map(e -> g[e], Indices(edges(g, qe)))

# Interface functions
Base.getindex(g::AbstractGraph, qv::QuotientVertex) = get_quotient_vertex_data(g, qv)
Base.getindex(g::AbstractGraph, qe::QuotientEdge) = get_quotient_edge_data(g, qe)

# For ambiguity resolution
Base.getindex(g::AbstractDataGraph, qv::QuotientVertex) = get_quotient_vertex_data(g, qv)
Base.getindex(g::AbstractDataGraph, qe::QuotientEdge) = get_quotient_edge_data(g, qe)

# QuotientView; make sure quotient views of data graphs do data graph indexing.
function Base.getindex(qv::QuotientView{V, <:AbstractDataGraph}, v) where {V}
    return _getindex(qv, v)
end
_getindex(qv::QuotientView, v) = parent(qv)[QuotientVertex(v)]
_getindex(qv::QuotientView, e::Union{Pair, AbstractEdge}) = parent(qv)[QuotientEdge(e)]

DataGraphs.vertex_data_eltype(qv::QuotientView) = DataGraphs.vertex_data_eltype(typeof(qv))
DataGraphs.vertex_data_eltype(T::Type{<:QuotientView}) = eltype(Base.promote_op(vertex_data, T))

DataGraphs.edge_data_eltype(qv::QuotientView) = DataGraphs.edge_data_eltype(typeof(qv))
DataGraphs.edge_data_eltype(T::Type{<:QuotientView}) = eltype(Base.promote_op(edge_data, T))

DataGraphs.underlying_graph(qv::QuotientView) = underlying_graph(copy(qv))

# PartitionedGraphs interface
function PartitionedGraphs.partitioned_vertices(dg::AbstractDataGraph)
    return partitioned_vertices(underlying_graph(dg))
end

PartitionedGraphs.partitionedgraph(::AbstractDataGraph, parts) = not_implemented()
PartitionedGraphs.departition(::AbstractDataGraph) = not_implemented()

# TODO: These methods wont be necessary once DataGraphs pivots to a `get/setindex`-based interface.
function DataGraphs.vertex_data(g::QuotientView)
    vs = Indices(vertices(g))
    return map(v -> getindex(parent(g), QuotientVertex(v)), vs)
end
function DataGraphs.edge_data(g::QuotientView)
    es = Indices(edges(g))
    return map(e -> getindex(parent(g), QuotientEdge(e)), es)
end

end

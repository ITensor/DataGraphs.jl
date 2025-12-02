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

#====INTERFACE FUNCTIONS====#
Base.getindex(g::AbstractGraph, qv::QuotientVertex) = get_quotient_vertex_data(g, qv)
Base.getindex(g::AbstractGraph, qe::QuotientEdge) = get_quotient_edge_data(g, qe)

# The type of `val` should be the return type of the corresponding `getindex` method.
Base.setindex!(g::AbstractGraph, val, qv::QuotientVertex) = set_quotient_vertex_data!(g, val, qv)
Base.setindex!(g::AbstractGraph, val, qe::QuotientEdge) = set_quotient_edge_data!(g, val, qe)
#====#

# Fallbacks
get_quotient_vertex_data(g::AbstractGraph, qv) = map(v -> g[v], Indices(vertices(g, qv)))
get_quotient_edge_data(g::AbstractGraph, qe) = map(e -> g[e], Indices(edges(g, qe)))

function set_quotient_vertex_data!(g::AbstractGraph, val, qv)
    for v in vertices(g, qv)
        g[v] = val[v]
    end
    return g
end
function set_quotient_edge_data!(g::AbstractGraph, val, qe)
    for e in edges(g, qe)
        g[e] = val[e]
    end
    return g
end

# For ambiguity resolution
Base.getindex(g::AbstractDataGraph, qv::QuotientVertex) = get_quotient_vertex_data(g, qv)
Base.getindex(g::AbstractDataGraph, qe::QuotientEdge) = get_quotient_edge_data(g, qe)

Base.setindex!(g::AbstractDataGraph, val, qv::QuotientVertex) = set_quotient_vertex_data!(g, val, qv)
Base.setindex!(g::AbstractDataGraph, val, qe::QuotientEdge) = set_quotient_edge_data!(g, val, qe)

# QuotientView; make sure quotient views of data graphs do data graph indexing.
Base.getindex(qv::QuotientView{V, <:AbstractDataGraph}, v) where {V} = _getindex(qv, v)
_getindex(qv::QuotientView, v) = getindex(parent(qv), QuotientVertex(v))
_getindex(qv::QuotientView, e::AbstractEdge) = getindex(parent(qv), QuotientEdge(e))

Base.setindex!(qv::QuotientView, ve) = _getindex(qv, ve)
_setindex!(qv::QuotientView, val, v) = setindex!(parent(qv), val, QuotientEdge(v))
_setindex!(qv::QuotientView, val, e::AbstractEdge) = setindex!(parent(qv), val, QuotientEdge(e))

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

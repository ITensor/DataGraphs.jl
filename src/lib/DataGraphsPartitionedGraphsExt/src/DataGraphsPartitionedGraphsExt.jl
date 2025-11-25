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
    partitioned_vertices
using Dictionaries: Dictionary, Indices

"""
    to_quotient_vertex_data(g::AbstractGraph{V}, data::Pair{QuotientVertex, Dictionary{V}})

Transform `data` obtained from the vertices in the quotient vertex of the graph `g` to a format
on the quotient graph of `g`. By default, this function returns `value` of the pair
`key, value = data` and should be specialized for specific graph types as needed.
"""
to_quotient_vertex_data(::AbstractGraph, data) = last(data)
"""
    to_quotient_edge_data(g::AbstractGraph, data::Pair{QuotientEdge, Dictionary{AbstractEdge}})

Transform `data` obtained from the edges in the quotient edge of the graph `g` to a format
on the quotient graph of `g`. By default, this function returns `value` of the pair
`key, value = data` and should be specialized for specific graph types as needed.
"""
to_quotient_edge_data(::AbstractGraph, data) = last(data)

# Ambiguity resolution
function Base.getindex(g::AbstractGraph, qve::Union{QuotientVertex, QuotientEdge})
    return _getindex(g, qve)
end
function Base.getindex(g::AbstractDataGraph, qve::Union{QuotientVertex, QuotientEdge})
    return _getindex(g, qve)
end
function _getindex(g::AbstractGraph, qv::QuotientVertex)
    vs = Indices(vertices(g, qv))
    return to_quotient_vertex_data(g, qv => map(v -> g[v], vs))
end
function _getindex(g::AbstractGraph, qe::QuotientEdge)
    es = Indices(edges(g, qe))
    return to_quotient_edge_data(g, qe => map(e -> g[e], es))
end

# QuotientView; make sure views of data graphs do data graph indexing.
function Base.getindex(qv::QuotientView{V, <:AbstractDataGraph}, v) where {V}
    return _getindex(qv, v)
end

_getindex(qv::QuotientView, v) = vertex_data(qv)[v]
_getindex(qv::QuotientView, e::Union{Pair, AbstractEdge}) = edge_data(qv)[e]

# QuotientView DataGraphs interface
function DataGraphs.vertex_data(qv::QuotientView)
    return Dictionary(map(v -> parent(qv)[QuotientVertex(v)], Indices(vertices(qv))))
end
function DataGraphs.edge_data(qv::QuotientView)
    return Dictionary(map(e -> parent(qv)[QuotientEdge(e)], Indices(edges(qv))))
end

DataGraphs.vertex_data_eltype(qv::QuotientView) = DataGraphs.vertex_data_eltype(typeof(qv))
DataGraphs.vertex_data_eltype(T::Type{<:QuotientView}) = eltype(Base.promote_op(vertex_data, T))

DataGraphs.edge_data_eltype(qv::QuotientView) = DataGraphs.edge_data_eltype(typeof(qv))
DataGraphs.edge_data_eltype(T::Type{<:QuotientView}) = eltype(Base.promote_op(edge_data, T))

# PartitionedGraphs interface
function PartitionedGraphs.partitioned_vertices(dg::AbstractDataGraph)
    return partitioned_vertices(underlying_graph(dg))
end

PartitionedGraphs.partitionedgraph(::AbstractDataGraph, parts) = not_implemented()
PartitionedGraphs.departition(::AbstractDataGraph) = not_implemented()

end

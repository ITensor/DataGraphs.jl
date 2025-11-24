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

function Base.getindex(g::AbstractGraph, qv::QuotientVertex)
    vs = Indices(vertices(g, qv))
    return to_quotient_vertex_data(g, qv => map(v -> g[v], vs))
end
function Base.getindex(g::AbstractGraph, qe::QuotientEdge)
    es = Indices(edges(g, qe))
    return to_quotient_edge_data(g, qe => map(e -> g[e], es))
end

# QuotientView
Base.getindex(qv::QuotientView, v) = _getindex(qv, v)

_getindex(qv::QuotientView, v) = parent(qv)[QuotientVertex(v)]
_getindex(qv::QuotientView, e::Union{Pair, AbstractEdge}) = parent(qv)[QuotientEdge(e)]

DataGraphs.vertex_data(qv::QuotientView) = Dictionary(map(v -> qv[v], Indices(vertices(qv))))
DataGraphs.edge_data(qv::QuotientView) = Dictionary(map(e -> qv[e], Indices(edges(qv))))

# PartitionedGraphs interface
function PartitionedGraphs.partitioned_vertices(dg::AbstractDataGraph)
    return partitioned_vertices(underlying_graph(dg))
end

PartitionedGraphs.partitionedgraph(::AbstractDataGraph, parts) = not_implemented()

end

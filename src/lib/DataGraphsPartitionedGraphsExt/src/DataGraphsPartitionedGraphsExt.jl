module DataGraphsPartitionedGraphsExt
using NamedGraphs.PartitionedGraphs: AbstractPartitionedGraph
using NamedGraphs.PartitionedGraphs: quotient_graph_vertextype
using Graphs: Graphs, AbstractGraph, AbstractEdge, vertices, edges
using ..DataGraphs:
    DataGraph,
    _DataGraph,
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
    set_index_data!,
    set_vertex_data!,
    set_edge_data!,
    set_vertices_data!,
    set_edges_data!,
    is_index_assigned,
    is_vertex_assigned,
    is_edge_assigned,
    vertices_data_eltype,
    edges_data_eltype,
    get_index_data
using NamedGraphs: NamedGraphs,
    to_graph_index,
    Vertices,
    Edges,
    to_edges,
    to_vertices,
    get_graph_index
using NamedGraphs.GraphsExtensions: vertextype, subgraph, edge_subgraph
using NamedGraphs.PartitionedGraphs:
    QuotientVertexSlice,
    QuotientEdgeSlice,
    PartitionedGraphs,
    QuotientEdge,
    QuotientEdgeEdge,
    QuotientEdges,
    QuotientEdgeEdges,
    QuotientVertex,
    QuotientVertexOrEdge,
    QuotientVertexVertex,
    QuotientVertexVertices,
    QuotientVerticesVertices,
    QuotientVertices,
    QuotientView,
    partitioned_vertices,
    quotientvertices,
    quotientedges,
    parent_graph_type,
    unpartitioned_graph,
    quotient_graph,
    partitionedgraph,
    departition,
    has_quotientvertex,
    has_quotientedge
using Dictionaries: Dictionary, Indices

# ======================== DataGraphs interface for QuotientView ========================= #

function NamedGraphs.get_graph_index(qv::QuotientView{<:Any, <:AbstractDataGraph}, ind)
    return DataGraphs.get_index_data(qv, ind)
end

function DataGraphs.get_vertex_data(qv::QuotientView, v)
    return getindex(parent(qv), QuotientVertex(v))
end

function DataGraphs.get_edge_data(qv::QuotientView, v)
    return getindex(parent(qv), QuotientEdge(v))
end

function DataGraphs.is_vertex_assigned(qv::QuotientView, v)
    return isassigned(parent(qv), QuotientVertex(v))
end

function DataGraphs.is_edge_assigned(qv::QuotientView, v)
    return isassigned(parent(qv), QuotientEdge(v))
end

function DataGraphs.set_vertex_data!(qv::QuotientView, val, v)
    return setindex!(parent(qv), val, QuotientVertex(v))
end
function DataGraphs.set_edge_data!(qv::QuotientView, val, e)
    return setindex!(parent(qv), val, QuotientEdge(e))
end

# ====================== DataGraphs interface for PartitionedGraphs ====================== #

function NamedGraphs.get_graph_index(pg::AbstractPartitionedGraph{<:Any, <:AbstractDataGraph}, ind)
    return DataGraphs.get_index_data(pg, ind)
end

function DataGraphs.get_vertex_data(pg::AbstractPartitionedGraph, v)
    return getindex(unpartitioned_graph(pg), v)
end

function DataGraphs.get_edge_data(pg::AbstractPartitionedGraph, e)
    return getindex(unpartitioned_graph(pg), e)
end

function DataGraphs.is_vertex_assigned(pg::AbstractPartitionedGraph, v)
    return isassigned(unpartitioned_graph(pg), v)
end

function DataGraphs.is_edge_assigned(pg::AbstractPartitionedGraph, e)
    return isassigned(unpartitioned_graph(pg), e)
end

function DataGraphs.set_vertex_data!(pg::AbstractPartitionedGraph, val, v)
    return setindex!(unpartitioned_graph(pg), val, v)
end
function DataGraphs.set_edge_data!(pg::AbstractPartitionedGraph, val, e)
    return setindex!(unpartitioned_graph(pg), val, e)
end

# =========================== Quotient indexing for DataGraphs =========================== #

function DataGraphs.get_index_data(graph::AbstractGraph, vertex::QuotientVertex)
    if !isassigned(graph, vertex)
        return subgraph(graph, vertex)
    else
        throw(MethodError(get_index_data, (graph, vertex)))
    end
end
function DataGraphs.get_index_data(graph::AbstractGraph, edge::QuotientEdge)
    if !isassigned(graph, edge)
        return edge_subgraph(graph, edge)
    else
        throw(MethodError(get_index_data, (graph, edge)))
    end
end
DataGraphs.is_index_assigned(graph::AbstractGraph, ind::QuotientVertexOrEdge) = false
function DataGraphs.set_index_data!(graph::AbstractGraph, value, ind::QuotientVertexOrEdge)
    return throw(MethodError(set_index_data!, (graph, value, ind)))
end

function DataGraphs.vertex_data_type(T::Type{<:QuotientView})
    PGT = parent_graph_type(T)
    return Base.promote_op(get_index_data, PGT, QuotientVertex{vertextype(T)})
end
function DataGraphs.edge_data_type(T::Type{<:QuotientView})
    PGT = parent_graph_type(T)
    return Base.promote_op(get_index_data, PGT, QuotientEdge{vertextype(T), edgetype(T)})
end

DataGraphs.underlying_graph(qv::QuotientView) = underlying_graph(copy(qv))

Base.isassigned(qv::QuotientView, ind) = DataGraphs.isassigned_datagraph(qv, to_graph_index(qv, ind))
Base.setindex!(qv::QuotientView, val, ind) = DataGraphs.setindex!_datagraph(qv, val, to_graph_index(qv, ind))

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

# ================================== DataGraph specific ================================== #

function PartitionedGraphs.partitionedgraph(dg::DataGraph, parts)
    pg = partitionedgraph(underlying_graph(dg), parts)
    vd = copy(vertex_data(dg))
    ed = copy(edge_data(dg))
    return _DataGraph(pg, vd, ed)
end

function PartitionedGraphs.departition(dg::DataGraph)
    ug = underlying_graph(dg)
    upg = departition(underlying_graph(dg))
    if upg === ug
        return dg
    else
        vd = copy(vertex_data(dg))
        ed = copy(edge_data(dg))
        return _DataGraph(upg, vd, ed)
    end
end

function quotient_graph_vertex_data(f, dg)
    ug = underlying_graph(dg)
    qvs = QuotientVertexSlice(QuotientVertices(ug))
    return map(v -> f(dg[QuotientVertex(v)]), Indices(qvs))
end

function quotient_graph_edge_data(f, dg)
    ug = underlying_graph(dg)
    qes = QuotientEdgeSlice(QuotientEdges(ug))
    return map(e -> f(dg[QuotientEdge(e)]), Indices(qes))
end

function PartitionedGraphs.quotient_graph(
        dg::DataGraph;
        vertex_data_transform = identity,
        edge_data_transform = identity
    )

    vertex_data = quotient_graph_vertex_data(vertex_data_transform, dg)
    edge_data = quotient_graph_edge_data(edge_data_transform, dg)

    dg = _DataGraph(
        copy(quotient_graph(underlying_graph(dg))),
        vertex_data,
        edge_data
    )
    return dg
end

# Need this to opt into partition-preserving subgraphing.
NamedGraphs.to_vertices(::AbstractDataGraph, qvsvs::QuotientVerticesVertices) = qvsvs

end

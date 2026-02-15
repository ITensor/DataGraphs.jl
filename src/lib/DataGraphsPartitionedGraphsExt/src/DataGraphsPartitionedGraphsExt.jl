module DataGraphsPartitionedGraphsExt
using ..DataGraphs: AbstractDataGraph, DataGraph, DataGraphs, _DataGraph, _getindex,
    edge_data, edgetype, get_edge_data, get_edges_data, get_index_data, get_vertex_data,
    get_vertices_data, is_edge_assigned, is_graph_index_assigned, is_vertex_assigned,
    set_edge_data!, set_edges_data!, set_index_data!, set_vertex_data!, set_vertices_data!,
    underlying_graph, vertex_data
using Dictionaries: Dictionary, IndexError, Indices
using Graphs: Graphs, AbstractEdge, AbstractGraph, edges, vertices
using NamedGraphs.GraphsExtensions:
    add_vertices!, edge_subgraph, similar_graph, subgraph, vertextype
using NamedGraphs.PartitionedGraphs: AbstractPartitionedGraph, PartitionedGraph,
    PartitionedGraphs, PartitionedView, QuotientEdge, QuotientEdgeEdge, QuotientEdgeEdges,
    QuotientEdgeSlice, QuotientEdges, QuotientVertex, QuotientVertexOrEdge,
    QuotientVertexSlice, QuotientVertexVertex, QuotientVertexVertices, QuotientVertices,
    QuotientVerticesVertices, QuotientView, departition, has_quotientedge,
    has_quotientvertex, parent_graph_type, partitioned_vertices, partitionedgraph,
    quotient_graph, quotient_graph_vertextype, quotientedges, quotientvertex,
    quotientvertices, unpartitioned_graph
using NamedGraphs:
    NamedGraphs, Edges, Vertices, get_graph_index, to_edges, to_graph_index, to_vertices

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
    setindex!(parent(qv), val, QuotientVertex(v))
    return qv
end
function DataGraphs.set_edge_data!(qv::QuotientView, val, e)
    setindex!(parent(qv), val, QuotientEdge(e))
    return qv
end

DataGraphs.underlying_graph(qv::QuotientView) = underlying_graph(copy(qv))

function Base.isassigned(qv::QuotientView, ind)
    return DataGraphs.isassigned_datagraph(qv, to_graph_index(qv, ind))
end
function Base.setindex!(qv::QuotientView, val, ind)
    return DataGraphs.setindex!_datagraph(qv, val, to_graph_index(qv, ind))
end

# ====================== DataGraphs interface for PartitionedGraphs ====================== #

function NamedGraphs.get_graph_index(
        pg::PartitionedGraph{<:Any, <:Any, <:AbstractDataGraph},
        ind
    )
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
    setindex!(unpartitioned_graph(pg), val, v)
    return pg
end
function DataGraphs.set_edge_data!(pg::AbstractPartitionedGraph, val, e)
    setindex!(unpartitioned_graph(pg), val, e)
    return pg
end

function Base.isassigned(pg::AbstractPartitionedGraph, ind)
    return DataGraphs.isassigned_datagraph(pg, to_graph_index(pg, ind))
end
function Base.setindex!(pg::AbstractPartitionedGraph, val, ind)
    return DataGraphs.setindex!_datagraph(pg, val, to_graph_index(pg, ind))
end

function NamedGraphs.to_graph_index(
        ::PartitionedGraph{<:Any, <:Any, <:AbstractDataGraph},
        qv::QuotientVertex
    )
    return qv
end
function NamedGraphs.to_graph_index(
        ::PartitionedGraph{<:Any, <:Any, <:AbstractDataGraph},
        qe::QuotientEdge
    )
    return qe
end

function DataGraphs.get_index_data(graph::PartitionedGraph, ind::QuotientVertex)
    return graph.quotient_graph[parent(ind)]
end
function DataGraphs.get_index_data(graph::PartitionedGraph, ind::QuotientEdge)
    return graph.quotient_graph[parent(ind)]
end

function DataGraphs.is_graph_index_assigned(graph::PartitionedGraph, ind::QuotientVertex)
    return isassigned(graph.quotient_graph, parent(ind))
end
function DataGraphs.is_graph_index_assigned(graph::PartitionedGraph, ind::QuotientEdge)
    return isassigned(graph.quotient_graph, parent(ind))
end

function DataGraphs.set_index_data!(graph::PartitionedGraph, val, ind::QuotientVertex)
    graph.quotient_graph[parent(ind)] = val
    return graph
end
function DataGraphs.set_index_data!(graph::PartitionedGraph, val, ind::QuotientEdge)
    graph.quotient_graph[parent(ind)] = val
    return graph
end

# =========================== Quotient indexing for DataGraphs =========================== #

function DataGraphs.get_index_data(::AbstractGraph, vertex::QuotientVertex)
    throw(IndexError("Quotient vertex $vertex not assigned"))
end
function DataGraphs.get_index_data(::AbstractGraph, edge::QuotientEdge)
    throw(IndexError("Quotient edge $edge not assigned"))
end
DataGraphs.is_graph_index_assigned(graph::AbstractGraph, ind::QuotientVertexOrEdge) = false
function DataGraphs.set_index_data!(graph::AbstractGraph, value, ind::QuotientVertexOrEdge)
    return throw(MethodError(set_index_data!, (graph, value, ind)))
end

function DataGraphs.vertex_data_type(T::Type{<:QuotientView})
    PGT = parent_graph_type(T)
    return Base.promote_op(getindex, PGT, QuotientVertex{vertextype(T)})
end
function DataGraphs.edge_data_type(T::Type{<:QuotientView})
    PGT = parent_graph_type(T)
    return Base.promote_op(getindex, PGT, QuotientEdge{vertextype(T), edgetype(T)})
end

# PartitionedGraphs interface
function PartitionedGraphs.partitioned_vertices(dg::AbstractDataGraph)
    return partitioned_vertices(underlying_graph(dg))
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

    # Check if underlying graph is already unpartitioned...
    if upg === ug
        # ...and return the graph itself such that `unpartition` can terminate correctly.
        # `unpartition` requires === to terminate its recursion.
        return dg
    else
        vd = copy(vertex_data(dg))
        ed = copy(edge_data(dg))
        return _DataGraph(upg, vd, ed)
    end
end

function quotient_graph_vertex_data(dg)
    ug = underlying_graph(dg)
    qvs = QuotientVertexSlice(QuotientVertices(ug))
    return map(v -> dg[QuotientVertex(v)], Indices(qvs))
end

function quotient_graph_edge_data(dg)
    ug = underlying_graph(dg)
    qes = QuotientEdgeSlice(QuotientEdges(ug))
    return map(e -> dg[QuotientEdge(e)], Indices(qes))
end

function PartitionedGraphs.quotient_graph(
        dg::DataGraph
    )
    vertex_data = quotient_graph_vertex_data(dg)
    edge_data = quotient_graph_edge_data(dg)

    dg = _DataGraph(
        copy(quotient_graph(underlying_graph(dg))),
        vertex_data,
        edge_data
    )
    return dg
end

# TODO: NamedGraphs.PartitionedGraphs needs a notion of `induced_quotient_graph`, which
# would largely replace this definition.
function PartitionedGraphs.quotient_graph(
        g::PartitionedView{<:Any, PV, <:DataGraph}
    ) where {PV}
    ug = unpartitioned_graph(g)

    sg = similar_graph(underlying_graph(ug), PV)
    qg = DataGraph(
        sg;
        vertex_data_type = Base.promote_op(subgraph, typeof(g), QuotientVertex{PV}),
        edge_data_type = Base.promote_op(
            edge_subgraph,
            typeof(g),
            QuotientEdge{PV, edgetype(sg)}
        )
    )

    add_vertices!(qg, keys(partitioned_vertices(g)))

    for v in vertices(qg)
        qg[v] = g[QuotientVertex(v)]
    end

    for e in edges(g)
        qv_src = parent(quotientvertex(g, src(e)))
        qv_dst = parent(quotientvertex(g, dst(e)))
        qe = edgetype(qg)(qv_src => qv_dst)
        if qv_src != qv_dst && !has_edge(qg, qe)
            add_edge!(qg, qe)
            qg[qe] = g[QuotientEdge(e)]
        end
    end

    return qg
end

# Need this to opt into partition-preserving subgraphing.
NamedGraphs.to_vertices(::AbstractDataGraph, qvsvs::QuotientVerticesVertices) = qvsvs

end

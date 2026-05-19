using Dictionaries: Dictionaries, Indices, isinsertable, set!
using Graphs: edges, edgetype, has_edge, has_vertex, rem_edge!, rem_vertex!, vertices
using NamedGraphs: NamedGraphs, Vertices, similar_graph, subgraph_edges, to_graph_index

abstract type AbstractVertexOrEdgeDataGraph{T, V} <: AbstractDataGraph{V, T, T} end

Graphs.edgetype(graph::AbstractVertexOrEdgeDataGraph) = edgetype(typeof(graph))

function NamedGraphs.similar_graph(
        graph::AbstractVertexOrEdgeDataGraph
    )
    return similar_graph(graph, valtype(graph))
end

function NamedGraphs.similar_graph(
        graph::AbstractVertexOrEdgeDataGraph,
        vertices
    )
    return similar_graph(graph, valtype(graph), vertices)
end
function NamedGraphs.similar_graph(
        graph::AbstractVertexOrEdgeDataGraph,
        T::Type,
        vertices
    )
    return similar_graph(graph, T, Vertices(vertices))
end

# For ambiguity resolution only.
function NamedGraphs.similar_graph(
        graph::AbstractVertexOrEdgeDataGraph,
        VD::Type,
        ED::Type
    )
    # No notion of both vertex and edge data, will go to `AbstractDataGraph` fallback.
    new_graph = similar_graph(graph, VD, ED, vertices(graph)) # -> DataGraph
    add_edges!(new_graph, edges(graph))
    return new_graph
end

function Base.copy(graph::AbstractVertexOrEdgeDataGraph)
    graph_dst = similar_graph(graph)
    # Allow copies of graphs with undefined data.
    copyto!(graph_dst, graph, filter(key -> isassigned(graph, key), keys(graph)))
    return graph_dst
end

function Base.copyto!(graph_dst::AbstractVertexOrEdgeDataGraph, src)
    copyto!(graph_dst, src, keys(src))
    return graph_dst
end

Base.iterate(graph::AbstractVertexOrEdgeDataGraph) = iterate(index_data(graph))
function Base.iterate(graph::AbstractVertexOrEdgeDataGraph, state)
    return iterate(index_data(graph), state)
end

Base.keytype(graph::AbstractVertexOrEdgeDataGraph) = keytype(typeof(graph))

Base.valtype(graph::AbstractVertexOrEdgeDataGraph) = valtype(typeof(graph))
Base.valtype(::Type{<:AbstractVertexOrEdgeDataGraph{T}}) where {T} = T

Base.eltype(graph::AbstractVertexOrEdgeDataGraph) = eltype(typeof(graph))
Base.eltype(::Type{<:AbstractVertexOrEdgeDataGraph{T}}) where {T} = T

Base.length(graph::AbstractVertexOrEdgeDataGraph) = length(index_data(graph))
Base.keys(graph::AbstractVertexOrEdgeDataGraph) = keys(index_data(graph))
Base.values(graph::AbstractVertexOrEdgeDataGraph) = values(index_data(graph))

Dictionaries.issettable(::AbstractVertexOrEdgeDataGraph) = true
Dictionaries.isinsertable(::AbstractVertexOrEdgeDataGraph) = false

function Base.insert!(graph::AbstractVertexOrEdgeDataGraph, ind, data)
    isinsertable(graph) || throw(ArgumentError("Graph does not support insertion."))
    insert!_datagraph(graph, to_graph_index(graph, ind), data)
    return graph
end

function Base.delete!(graph::AbstractVertexOrEdgeDataGraph, ind)
    delete!_datagraph(graph, to_graph_index(graph, ind))
    return graph
end

function Dictionaries.set!(graph::AbstractVertexOrEdgeDataGraph, ind, data)
    set!_datagraph(graph, to_graph_index(graph, ind), data)
    return graph
end

# ================================== vertex data graph =================================== #

abstract type AbstractVertexDataGraph{T, V} <: AbstractVertexOrEdgeDataGraph{T, V} end

Base.keytype(::Type{<:AbstractVertexDataGraph{T, V}}) where {T, V} = V

is_edge_assigned(::AbstractVertexDataGraph, _edge) = false

# `setindex!`
function set_index_data!(graph::AbstractVertexDataGraph, data, vertex)
    if !has_vertex(graph, vertex)
        throw(IndexError("Graph does not contain vertex $vertex"))
    end
    set_vertex_data!(graph, data, vertex)
    return graph
end

# `insert!`
function insert!_datagraph(graph::AbstractVertexDataGraph, vertex, data)
    if has_vertex(graph, vertex)
        throw(IndexError("Graph already contains vertex $vertex"))
    end
    insert_vertex_data!(graph, vertex, data)
    return graph
end

# `delete!`
function delete!_datagraph(graph::AbstractVertexDataGraph, vertex)
    if !has_vertex(graph, vertex)
        throw(IndexError("Graph does not contain vertex $vertex"))
    end
    rem_vertex!(graph, vertex)
    return graph
end

# `set!`
function set!_datagraph(graph::AbstractVertexDataGraph, vertex, data)
    if has_vertex(graph, vertex)
        graph[vertex] = data
    else
        insert!(graph, vertex, data)
    end
    return graph
end

function NamedGraphs.similar_graph(
        graph::AbstractVertexDataGraph,
        T::Type
    )
    new_graph = similar_graph(graph, T, vertices(graph))
    # we can add edges to a `AbstractVertexDataGraph`.
    add_edges!(new_graph, edges(graph))
    return new_graph
end

# Base method to overload.
function NamedGraphs.similar_graph(
        ::AbstractVertexDataGraph,
        T::Type,
        vertices::Vertices
    )
    return similar_graph(VertexDataGraph{T}, vertices)
end

function NamedGraphs.induced_subgraph_from_vertices(
        graph::AbstractVertexDataGraph,
        subvertices
    )
    subnetwork = similar_graph(graph, subvertices)
    add_edges!(subnetwork, subgraph_edges(graph, subvertices))
    tensors = view(vertex_data(graph), Indices(subvertices))
    copyto!(subnetwork, tensors)
    return subnetwork, subvertices
end

# Internal
index_data(graph::AbstractVertexDataGraph) = vertex_data(graph)

function Base.show(io::IO, mime::MIME"text/plain", graph::AbstractVertexDataGraph)
    println(io, "$(typeof(graph)) with $(nv(graph)) vertices:")
    show(io, mime, vertices(graph))
    println(io, "\n")
    println(io, "and $(ne(graph)) edge(s):")
    for e in edges(graph)
        show(io, mime, e)
        println(io)
    end
    println(io)
    println(io, "with vertex data:")
    show(io, mime, vertex_data(graph))
    return nothing
end

# =================================== edge data graph ==================================== #

abstract type AbstractEdgeDataGraph{T, V} <: AbstractVertexOrEdgeDataGraph{T, V} end

Base.keytype(::Type{<:AbstractEdgeDataGraph{T, V}}) where {T, V} = NamedEdge{V}

is_vertex_assigned(::AbstractEdgeDataGraph, _vertex) = false

# `setindex!`
function set_index_data!(graph::AbstractEdgeDataGraph, data, edge::AbstractEdge)
    v1 = src(edge)
    v2 = dst(edge)
    if !has_vertex(graph, v1)
        throw(IndexError("Graph does not contain vertex $v1"))
    elseif !has_vertex(graph, v2)
        throw(IndexError("Graph does not contain vertex $v2"))
    end
    set_edge_data!(graph, data, edge)
    return graph
end

# `insert!`
function insert!_datagraph(graph::AbstractEdgeDataGraph, edge::AbstractEdge, data)
    v1 = src(edge)
    v2 = dst(edge)
    if has_vertex(graph, v1) && has_vertex(graph, v2)
        throw(IndexError("Graph already contains vertices $v1 and $v2"))
    end
    insert_edge_data!(graph, edge, data)
    return graph
end
function insert_edge_data!(graph::AbstractEdgeDataGraph, edge::AbstractEdge, data)
    v1 = src(edge)
    v2 = dst(edge)
    has_vertex(graph, v1) || add_vertex!(graph, v1)
    has_vertex(graph, v2) || add_vertex!(graph, v2)
    set_edge_data!(graph, data, edge)
    return graph
end

# `delete!`
function delete!_datagraph(graph::AbstractEdgeDataGraph, edge)
    if !has_edge(graph, edge)
        throw(IndexError("Graph does not contain edge $edge"))
    end
    rem_edge!(graph, edge)
    return graph
end

# `set!`
function set!_datagraph(graph::AbstractEdgeDataGraph, edge::AbstractEdge, data)
    if !has_vertex(graph, src(edge)) || !has_vertex(graph, dst(edge))
        insert!(graph, edge, data)
    else
        graph[edge] = data
    end
    return graph
end

function NamedGraphs.similar_graph(
        graph::AbstractEdgeDataGraph,
        T::Type
    )
    new_graph = similar_graph(graph, T, vertices(graph))
    # we can't generically add edges to an `AbstractEdgeDataGraph`.
    return new_graph
end

# Base method to overload.
function NamedGraphs.similar_graph(
        ::AbstractEdgeDataGraph,
        T::Type,
        vertices::Vertices
    )
    return similar_graph(EdgeDataGraph{T}, collect(vertices))
end

function NamedGraphs.induced_subgraph_from_vertices(
        graph::AbstractEdgeDataGraph,
        subvertices
    )
    subnetwork = similar_graph(graph, subvertices)
    subedges = subgraph_edges(graph, subvertices)

    tensors = view(edge_data(graph), Indices(subedges))

    copyto!(subnetwork, tensors)

    return subnetwork, subvertices
end

# Internal
index_data(graph::AbstractEdgeDataGraph) = edge_data(graph)

function Base.show(io::IO, mime::MIME"text/plain", graph::AbstractEdgeDataGraph)
    println(io, "$(typeof(graph)) with $(nv(graph)) vertices:")
    show(io, mime, vertices(graph))
    println(io, "\n")
    println(io, "and $(ne(graph)) edge(s):")
    for e in edges(graph)
        show(io, mime, e)
        println(io)
    end
    println(io)
    println(io, "with edge data:")
    show(io, mime, edge_data(graph))
    return nothing
end

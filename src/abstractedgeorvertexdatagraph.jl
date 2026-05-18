using Dictionaries: Dictionaries, Indices, set!
using Graphs: edges, edgetype, has_edge, has_vertex, rem_edge!, rem_vertex!, vertices
using NamedGraphs: NamedGraphs, Vertices, similar_graph, subgraph_edges, to_graph_index

abstract type AbstractVertexOrEdgeDataGraph{I, T, V} <: AbstractDataGraph{V, T, T} end

Graphs.edgetype(graph::AbstractVertexOrEdgeDataGraph) = edgetype(typeof(graph))

function NamedGraphs.similar_graph(
        graph::AbstractVertexOrEdgeDataGraph,
        T::Type
    )
    return similar_graph(graph, T, vertices(graph))
end

function NamedGraphs.similar_graph(
        graph::AbstractVertexOrEdgeDataGraph,
        T::Type,
        vertices
    )
    return similar_graph(graph, T, Vertices(vertices))
end

function Base.:(==)(dg1::AbstractVertexOrEdgeDataGraph, dg2::AbstractVertexOrEdgeDataGraph)
    return underlying_graph(dg1) == underlying_graph(dg2) &&
        index_data(dg1) == index_data(dg2)
end

function Base.copyto!(
        graph_dst::G,
        graph_src::G,
        keynames = nothing
    ) where {G <: AbstractVertexOrEdgeDataGraph}
    dict_src = index_data(graph_src)
    keynames = isnothing(keynames) ? keys(dict_src) : keynames
    copyto!(graph_dst, dict_src, keynames)
    return graph_dst
end

Base.iterate(graph::AbstractVertexOrEdgeDataGraph) = iterate(index_data(graph))
function Base.iterate(graph::AbstractVertexOrEdgeDataGraph, state)
    return iterate(index_data(graph), state)
end

Base.keytype(graph::AbstractVertexOrEdgeDataGraph) = keytype(typeof(graph))
Base.keytype(::Type{<:AbstractVertexOrEdgeDataGraph{I, T, V}}) where {I, T, V} = I

Base.valtype(graph::AbstractVertexOrEdgeDataGraph) = valtype(typeof(graph))
Base.valtype(::Type{<:AbstractVertexOrEdgeDataGraph{I, T, V}}) where {I, T, V} = T

Base.eltype(graph::AbstractVertexOrEdgeDataGraph) = eltype(typeof(graph))
Base.eltype(::Type{<:AbstractVertexOrEdgeDataGraph{I, T, V}}) where {I, T, V} = T

Base.length(graph::AbstractVertexOrEdgeDataGraph) = length(index_data(graph))
Base.keys(graph::AbstractVertexOrEdgeDataGraph) = keys(index_data(graph))
Base.values(graph::AbstractVertexOrEdgeDataGraph) = values(index_data(graph))

Dictionaries.issettable(::AbstractVertexOrEdgeDataGraph) = true
Dictionaries.isinsertable(::AbstractVertexOrEdgeDataGraph) = false

function Base.insert!(graph::AbstractVertexOrEdgeDataGraph, ind, data)
    insert!_datagraph(graph, to_graph_index(graph, ind), data)
    return graph
end
# For ambiguity resolution.
function Base.insert!(
        graph::AbstractVertexOrEdgeDataGraph{I, T},
        ind::I,
        data::T
    ) where {I, T}
    insert!_datagraph(graph, to_graph_index(graph, ind), data)
    return graph
end

function Base.delete!(graph::AbstractVertexOrEdgeDataGraph{I, T}, ind::T) where {I, T}
    delete!_datagraph(graph, to_graph_index(graph, ind))
    return graph
end

function Dictionaries.set!(graph::AbstractVertexOrEdgeDataGraph, ind, data)
    set!_datagraph(graph, to_graph_index(graph, ind), data)
    return graph
end

# ================================== vertex data graph =================================== #

abstract type AbstractVertexDataGraph{V, T} <: AbstractVertexOrEdgeDataGraph{V, T, V} end

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
        set_vertex_data!(graph, data, vertex)
    else
        insert_vertex_data!(graph, vertex, data)
    end
    return graph
end

# For ambiguity resolution.
function NamedGraphs.similar_graph(
        graph::AbstractVertexDataGraph,
        VD::Type,
        ED::Type
    )
    return similar_graph(graph, VD, ED, vertices(graph)) # goes to fallback
end

function NamedGraphs.similar_graph(
        graph::AbstractVertexDataGraph,
        VD::Type,
        ::Type{Nothing},
        vertices
    )
    return similar_graph(graph, VD, vertices)
end

function NamedGraphs.similar_graph(
        graph::AbstractVertexDataGraph,
        T::Type,
        vertices::Vertices
    )
    return DataGraph(
        similar_graph(underlying_graph(graph), collect(vertices));
        vertex_data_type = Nothing,
        edge_data_type = T
    )
end

function NamedGraphs.induced_subgraph_from_vertices(
        graph::AbstractVertexDataGraph,
        subvertices
    )
    subnetwork = similar_graph(graph, subvertices)
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

abstract type AbstractEdgeDataGraph{E, T, V} <: AbstractVertexOrEdgeDataGraph{E, T, V} end

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
        insert_edge_data!(graph, edge, data)
    else
        set_edge_data!(graph, data, edge)
    end
    return graph
end

# For ambiguity resolution.
function NamedGraphs.similar_graph(
        graph::AbstractEdgeDataGraph,
        VD::Type,
        ED::Type
    )
    return similar_graph(graph, VD, ED, vertices(graph)) # goes to fallback
end

function NamedGraphs.similar_graph(
        graph::AbstractEdgeDataGraph,
        ::Type{Nothing},
        ED::Type,
        vertices
    )
    return similar_graph(graph, ED, vertices)
end

function NamedGraphs.similar_graph(
        graph::AbstractEdgeDataGraph,
        T::Type,
        vertices::Vertices
    )
    return DataGraph(
        similar_graph(underlying_graph(graph), collect(vertices));
        vertex_data_type = Nothing,
        edge_data_type = T
    )
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

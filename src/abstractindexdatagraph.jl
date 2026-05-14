# ================================== vertex data graph =================================== #

const AbstractVertexDataGraph{V, VD} = AbstractDataGraph{V, VD, Nothing}

is_edge_assigned(::AbstractVertexDataGraph, _edge) = false

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
        ::Type{<:Nothing},
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

const AbstractEdgeDataGraph{V, ED} = AbstractDataGraph{V, Nothing, ED}

is_vertex_assigned(::AbstractEdgeDataGraph, _vertex) = false

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
        ::Type{<:Nothing},
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
    add_edges!(subnetwork, subedges)

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

# ============================= index graph (vertex or edge) ============================= #

const AbstractIndexDataGraph{V, T} =
    Union{AbstractVertexDataGraph{V, T}, AbstractEdgeDataGraph{V, T}}

function NamedGraphs.similar_graph(
        graph::AbstractIndexDataGraph,
        T::Type
    )
    return similar_graph(graph, T, vertices(graph))
end

function NamedGraphs.similar_graph(
        graph::AbstractIndexDataGraph,
        T::Type,
        vertices
    )
    return similar_graph(graph, T, Vertices(vertices))
end

function Base.:(==)(dg1::AbstractIndexDataGraph, dg2::AbstractIndexDataGraph)
    return underlying_graph(dg1) == underlying_graph(dg2) &&
        index_data(dg1) == index_data(dg2)
end

function copyto!_indexdatagraph(
        dst::AbstractIndexDataGraph,
        src, # not a graph.
        dimnames = nothing
    )
    dimnames = isnothing(dimnames) ? Indices(keys(src)) : Indices(dimnames)
    view(index_data(dst), dimnames) .= view(src, dimnames)
    return dst
end

function Base.copyto!(
        graph_dst::G,
        graph_src::G,
        dimnames = nothing
    ) where {G <: AbstractIndexDataGraph}
    copyto!_indexdatagraph(graph_dst, index_data(graph_src), dimnames)
    return graph_dst
end
function Base.copyto!(
        graph_dst::AbstractIndexDataGraph,
        dictionary_src::AbstractDictionary,
        dimnames = nothing
    )
    copyto!_indexdatagraph(graph_dst, dictionary_src, dimnames)
    return graph_dst
end

Base.iterate(graph::AbstractIndexDataGraph) = iterate(index_data(graph))
Base.iterate(graph::AbstractIndexDataGraph, state) = iterate(index_data(graph), state)

Base.keytype(::AbstractIndexDataGraph{V, T}) where {V, T} = V
Base.keytype(::Type{<:AbstractIndexDataGraph{V, T}}) where {V, T} = V

Base.valtype(::AbstractIndexDataGraph{V, T}) where {V, T} = T
Base.valtype(::Type{<:AbstractIndexDataGraph{V, T}}) where {V, T} = T

Base.eltype(::AbstractIndexDataGraph{V, T}) where {V, T} = T
Base.eltype(::Type{<:AbstractIndexDataGraph{V, T}}) where {V, T} = T

Base.keys(graph::AbstractIndexDataGraph) = keys(index_data(graph))
Base.length(graph::AbstractIndexDataGraph) = length(index_data(graph))

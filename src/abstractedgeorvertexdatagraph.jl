using Dictionaries: Dictionaries, Indices, isinsertable, set!
using Graphs: edges, edgetype, has_edge, has_vertex, rem_edge!, rem_vertex!, vertices
using NamedGraphs: NamedGraphs, Vertices, similar_graph, subgraph_edges, to_graph_index

abstract type AbstractVertexDataGraph{T, V} <: AbstractDataGraph{V, T, Nothing} end
abstract type AbstractEdgeDataGraph{T, V} <: AbstractDataGraph{V, Nothing, T} end

for GType in (:AbstractVertexDataGraph, :AbstractEdgeDataGraph)
    @eval begin
        Graphs.edgetype(graph::$GType) = edgetype(typeof(graph))

        function NamedGraphs.similar_graph(
                graph::$GType
            )
            return similar_graph(graph, valtype(graph))
        end

        function NamedGraphs.similar_graph(
                graph::$GType,
                vertices
            )
            return similar_graph(graph, valtype(graph), vertices)
        end

        function Base.copy(graph::$GType)
            graph_dst = similar_graph(graph)
            # Allow copies of graphs with undefined data.
            copyto!(graph_dst, graph, filter(key -> isassigned(graph, key), keys(graph)))
            return graph_dst
        end

        function Base.copyto!(graph_dst::$GType, src)
            copyto!(graph_dst, src, keys(src))
            return graph_dst
        end

        Base.iterate(graph::$GType) = iterate(index_data(graph))
        function Base.iterate(graph::$GType, state)
            return iterate(index_data(graph), state)
        end

        Base.keytype(graph::$GType) = keytype(typeof(graph))

        Base.valtype(graph::$GType) = valtype(typeof(graph))
        Base.valtype(::Type{<:$GType{T}}) where {T} = T

        Base.eltype(graph::$GType) = eltype(typeof(graph))
        Base.eltype(::Type{<:$GType{T}}) where {T} = T

        Base.length(graph::$GType) = length(index_data(graph))
        Base.keys(graph::$GType) = keys(index_data(graph))
        Base.values(graph::$GType) = values(index_data(graph))

        Dictionaries.issettable(::$GType) = true
        Dictionaries.isinsertable(::$GType) = false

        function Base.insert!(graph::$GType, ind, data)
            isinsertable(graph) || throw(ArgumentError("Graph does not support insertion."))
            insert!_datagraph(graph, to_graph_index(graph, ind), data)
            return graph
        end

        function Base.delete!(graph::$GType, ind)
            delete!_datagraph(graph, to_graph_index(graph, ind))
            return graph
        end

        function Dictionaries.set!(graph::$GType, ind, data)
            set!_datagraph(graph, to_graph_index(graph, ind), data)
            return graph
        end

        function Base.merge!(graph::$GType, other)
            for key in keys(other)
                set!(graph, key, other[key])
            end
            return graph
        end
    end
end

# ================================== vertex data graph =================================== #

Base.keytype(::Type{<:AbstractVertexDataGraph{T, V}}) where {T, V} = V

is_edge_assigned(::AbstractVertexDataGraph, _edge) = false

# For method ambiguity resolution,
# TODO: remove this method once generic `AbstractDataGraph` method is upgraded.
function set_index_data!(graph::AbstractVertexDataGraph, data, vertex::AbstractEdge)
    return throw(MethodError(graph, (data, vertex)))
end
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
        vertices
    )
    return similar_graph(VertexDataGraph{T}, vertices)
end

function NamedGraphs.induced_subgraph_from_vertices(
        graph::AbstractVertexDataGraph,
        subvertices
    )
    subnetwork = similar_graph(graph, subvertices)
    add_edges!(subnetwork, subgraph_edges(graph, subvertices))
    data = view(vertex_data(graph), Indices(subvertices))
    copyto!(subnetwork, data)
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

Base.keytype(::Type{<:AbstractEdgeDataGraph{T, V}}) where {T, V} = NamedEdge{V}

is_vertex_assigned(::AbstractEdgeDataGraph, _vertex) = false

# `setindex!`
function set_index_data!(graph::AbstractEdgeDataGraph, data, edge::AbstractEdge)
    if !has_edge(graph, edge)
        throw(IndexError("Graph does not contain edge $edge"))
    end
    set_edge_data!(graph, data, edge)
    return graph
end

# `insert!`
function insert!_datagraph(graph::AbstractEdgeDataGraph, edge::AbstractEdge, data)
    if has_edge(graph, edge)
        throw(IndexError("Graph already contains edge $edge"))
    end
    insert_edge_data!(graph, edge, data)
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
    if has_edge(graph, edge)
        graph[edge] = data
    else
        insert!(graph, edge, data)
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
        vertices
    )
    return similar_graph(EdgeDataGraph{T}, vertices)
end

function NamedGraphs.induced_subgraph_from_vertices(
        graph::AbstractEdgeDataGraph,
        subvertices
    )
    subnetwork = similar_graph(graph, subvertices)
    subedges = subgraph_edges(graph, subvertices)

    data = view(edge_data(graph), Indices(subedges))

    merge!(subnetwork, data)

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

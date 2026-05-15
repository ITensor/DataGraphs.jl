using Dictionaries: Dictionary, set!
using Graphs: Graphs, rem_vertex!
using NamedGraphs:
    NamedDiGraph, NamedGraph, ordered_vertices, position_graph, vertex_positions

struct VertexDataGraph{V, T} <: AbstractVertexDataGraph{V, T}
    underlying_graph::NamedGraph{V}
    vertex_data::Dictionary{V, T}
    function VertexDataGraph{V, T}(
            ::UndefInitializer,
            vertices
        ) where {V, T}
        graph = NamedGraph{V}(vertices)
        vertex_data = Dictionary{V, T}()
        return new{V, T}(graph, vertex_data)
    end
end

VertexDataGraph(data) = VertexDataGraph{keytype(data)}(data)
VertexDataGraph{V}(data) where {V} = VertexDataGraph{V, valtype(data)}(data)

struct VertexDataDiGraph{V, T} <: AbstractVertexDataGraph{V, T}
    underlying_graph::NamedDiGraph{V}
    vertex_data::Dictionary{V, T}
    function VertexDataDiGraph{V, T}(
            ::UndefInitializer,
            vertices
        ) where {V, T}
        graph = NamedDiGraph{V}(vertices)
        vertex_data = Dictionary{V, T}()
        return new{V, T}(graph, vertex_data)
    end
end

VertexDataDiGraph(data) = VertexDataDiGraph{keytype(data)}(data)
VertexDataDiGraph{V}(data) where {V} = VertexDataDiGraph{V, valtype(data)}(data)

const GenericVertexDataGraph{V, T} = Union{VertexDataGraph{V, T}, VertexDataDiGraph{V, T}}

function (GType::Type{<:GenericVertexDataGraph{V, T}})(data) where {V, T}
    vertices = keys(data)
    cache = GType(undef, vertices)
    return copyto!(cache, data)
end

Graphs.is_directed(::Type{<:VertexDataGraph}) = false
Graphs.is_directed(::Type{<:VertexDataDiGraph}) = true

# ====================================== Graphs.jl ======================================= #

function Graphs.rem_vertex!(graph::GenericVertexDataGraph, vertex)
    delete!(graph.vertex_data, vertex)
    rem_vertex!(graph.underlying_graph, vertex)
    return graph
end

Graphs.vertices(graph::GenericVertexDataGraph) = vertices(graph.underlying_graph)

# ==================================== NamedGraphs.jl ==================================== #

function NamedGraphs.vertex_positions(graph::GenericVertexDataGraph)
    return vertex_positions(graph.underlying_graph)
end

function NamedGraphs.ordered_vertices(graph::GenericVertexDataGraph)
    return ordered_vertices(graph.underlying_graph)
end

function NamedGraphs.position_graph(graph::GenericVertexDataGraph)
    return position_graph(graph.underlying_graph)
end

# ==================================== DataGraphs.jl ===================================== #

underlying_graph(graph::VertexDataGraph) = getfield(graph, :underlying_graph)
underlying_graph(graph::VertexDataDiGraph) = getfield(graph, :underlying_graph)

vertex_data_type(::Type{<:GenericVertexDataGraph{V, T}}) where {V, T} = T

function set_vertex_data!(graph::GenericVertexDataGraph, data, vertex)
    graph.vertex_data[vertex] = data
    return graph
end

get_vertex_data(graph::GenericVertexDataGraph, vertex) = graph.vertex_data[vertex]

function is_vertex_assigned(graph::GenericVertexDataGraph, vertex)
    return isassigned(graph.vertex_data, vertex)
end
is_edge_assigned(::GenericVertexDataGraph, _edge) = false

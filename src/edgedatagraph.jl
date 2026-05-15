using Graphs: dst, rem_edge!, rem_vertex!, src
using NamedGraphs: NamedEdge, NamedGraph, ordered_vertices, position_graph, vertex_positions

struct EdgeDataGraph{E <: NamedEdge{V} where {V}, T, V} <: AbstractEdgeDataGraph{E, T, V}
    underlying_graph::NamedGraph{V}
    edge_data::Dictionary{E, T}
    function EdgeDataGraph{E, T, V}(
            ::UndefInitializer,
            vertices
        ) where {V, E <: NamedEdge{V}, T}
        graph = NamedGraph{V}(vertices)
        edge_data = Dictionary{E, T}()
        return new{E, T, V}(graph, edge_data)
    end
end

EdgeDataGraph(data) = EdgeDataGraph{keytype(data)}(data)
EdgeDataGraph{I}(data) where {I} = EdgeDataGraph{I, valtype(data)}(data)
EdgeDataGraph{I, T}(data) where {I, T} = EdgeDataGraph{I, T, vertextype{I}}(data)

Graphs.is_directed(::Type{<:EdgeDataGraph}) = false

struct EdgeDataDiGraph{E <: NamedEdge{V} where {V}, T, V} <: AbstractEdgeDataGraph{E, T, V}
    underlying_graph::NamedDiGraph{V}
    edge_data::Dictionary{E, T}
    function EdgeDataDiGraph{E, T, V}(
            ::UndefInitializer,
            vertices
        ) where {V, E <: NamedEdge{V}, T}
        graph = NamedDiGraph{V}(vertices)
        edge_data = Dictionary{E, T}()
        return new{E, T, V}(graph, edge_data)
    end
end

EdgeDataDiGraph(data) = EdgeDataDiGraph{keytype(data)}(data)
EdgeDataDiGraph{I}(data) where {I} = EdgeDataDiGraph{I, valtype(data)}(data)
EdgeDataDiGraph{I, T}(data) where {I, T} = EdgeDataDiGraph{I, T, vertextype{I}}(data)

Graphs.is_directed(::Type{<:EdgeDataDiGraph}) = true

const GenericEdgeDataGraph{I, T, V} =
    Union{EdgeDataGraph{I, T, V}, EdgeDataDiGraph{I, T, V}}

function (GType::Type{<:GenericEdgeDataGraph{I, T, V}})(data) where {I, T, V}
    edges = keys(data)
    vertices = union(src.(edges), dst.(edges))
    cache = GType(undef, vertices)
    add_edges!(cache.underlying_graph, edges)
    return copyto!(cache, data)
end

# ====================================== Graphs.jl ======================================= #

function Graphs.rem_edge!(graph::GenericEdgeDataGraph, edge)
    rem_edge!(graph.underlying_graph, edge)
    delete!(graph.edge_data, edge)
    return graph
end

function Graphs.rem_vertex!(graph::GenericEdgeDataGraph, vertex)
    for edge in incident_edges(graph, vertex)
        delete!(graph.edge_data, edge)
    end
    rem_vertex!(graph.underlying_graph, vertex)
    return graph
end

Graphs.vertices(graph::GenericEdgeDataGraph) = vertices(graph.underlying_graph)

# ==================================== NamedGraphs.jl ==================================== #

function NamedGraphs.vertex_positions(graph::GenericEdgeDataGraph)
    return vertex_positions(graph.underlying_graph)
end

function NamedGraphs.ordered_vertices(graph::GenericEdgeDataGraph)
    return ordered_vertices(graph.underlying_graph)
end

function NamedGraphs.position_graph(graph::GenericEdgeDataGraph)
    return position_graph(graph.underlying_graph)
end

# ==================================== DataGraphs.jl ===================================== #

edge_data_type(::Type{<:GenericEdgeDataGraph{I, T}}) where {I, T} = T

function set_edge_data!(graph::GenericEdgeDataGraph, data, edge)
    graph.edge_data[edge] = data
    return graph
end

get_edge_data(graph::GenericEdgeDataGraph, edge) = graph.edge_data[edge]

is_vertex_assigned(::GenericEdgeDataGraph, _vertex) = false
is_edge_assigned(graph::GenericEdgeDataGraph, edge) = isassigned(graph.edge_data, edge)

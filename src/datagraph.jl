using Dictionaries: Dictionary
using Graphs: Graphs, edgetype
using Graphs.SimpleGraphs: SimpleGraph
using NamedGraphs.GraphsExtensions: convert_vertextype, directed_graph, vertextype

# TODO: define VertexDataGraph, a graph with only data on the
# vertices, and EdgeDataGraph, a graph with only data on the edges.
# TODO: Use https://github.com/vtjnash/ComputedFieldTypes.jl to
# automatically determine `E` from `G` from `edgetype(G)`
# and `V` from `G` as `vertextype(G)`.
struct DataGraph{V, VD, ED, G <: AbstractGraph, E <: AbstractEdge} <: AbstractDataGraph{V, VD, ED}
    underlying_graph::G
    vertex_data::Dictionary{V, VD}
    edge_data::Dictionary{E, ED}
    global function _DataGraph(
            underlying_graph::AbstractGraph, vertex_data::Dictionary, edge_data::Dictionary
        )
        return new{
            vertextype(underlying_graph),
            eltype(vertex_data),
            eltype(edge_data),
            typeof(underlying_graph),
            edgetype(underlying_graph),
        }(
            underlying_graph, vertex_data, edge_data
        )
    end
end
underlying_graph_type(G::Type{<:DataGraph}) = fieldtype(G, :underlying_graph)
vertex_data_eltype(G::Type{<:DataGraph}) = eltype(fieldtype(G, :vertex_data))
edge_data_eltype(G::Type{<:DataGraph}) = eltype(fieldtype(G, :edge_data))
underlying_graph(graph::DataGraph) = getfield(graph, :underlying_graph)
vertex_data(graph::DataGraph) = getfield(graph, :vertex_data)
edge_data(graph::DataGraph) = getfield(graph, :edge_data)

# TODO: Is this needed? Maybe define a generic `AbstractDataGraph` version.
Graphs.is_directed(G::Type{<:DataGraph}) = Graphs.is_directed(underlying_graph_type(G))

# TODO: Implement in terms of `set_underlying_graph`, `set_vertex_data`, etc.
# TODO: Use `https://github.com/JuliaObjects/Accessors.jl`?
function Base.copy(graph::DataGraph)
    # Need to manually copy the keys of Dictionaries, see:
    # https://github.com/andyferris/Dictionaries.jl/issues/98
    return _DataGraph(
        copy(underlying_graph(graph)), copy(vertex_data(graph)), copy(edge_data(graph))
    )
end

function DataGraph{V}(
        underlying_graph::AbstractGraph; vertex_data_eltype::Type = Any, edge_data_eltype::Type = Any
    ) where {V}
    converted_underlying_graph = convert_vertextype(V, underlying_graph)
    return _DataGraph(
        converted_underlying_graph,
        Dictionary{vertextype(converted_underlying_graph), vertex_data_eltype}(),
        Dictionary{edgetype(converted_underlying_graph), edge_data_eltype}(),
    )
end

function DataGraph(underlying_graph::AbstractGraph; kwargs...)
    return DataGraph{vertextype(underlying_graph)}(underlying_graph; kwargs...)
end

function DataGraph{V, VD, ED, G, E}(underlying_graph::AbstractGraph) where {V, VD, ED, G, E}
    @assert edgetype(underlying_graph) === E
    return _DataGraph(convert(G, underlying_graph), Dictionary{V, VD}(), Dictionary{E, ED}())
end

# Type conversions
DataGraph{V, VD, ED, G}(graph::DataGraph{V, VD, ED, G}) where {V, VD, ED, G} = copy(graph)
DataGraph{V, VD, ED}(graph::DataGraph{V, VD, ED}) where {V, VD, ED} = copy(graph)
DataGraph{V, VD}(graph::DataGraph{V, VD}) where {V, VD} = copy(graph)
DataGraph{V}(graph::DataGraph{V}) where {V} = copy(graph)

function DataGraph{V}(graph::DataGraph) where {V}
    # TODO: Make sure this properly copies
    converted_underlying_graph = convert_vertextype(V, underlying_graph(graph))
    converted_vertex_data = Dictionary{V}(vertex_data(graph))
    # This doesn't convert properly.
    # converted_edge_data = Dictionary{edgetype(converted_underlying_graph)}(edge_data(graph))
    converted_edge_data = Dictionary(
        edgetype(converted_underlying_graph).(keys(edge_data(graph))), values(edge_data(graph))
    )
    return _DataGraph(converted_underlying_graph, converted_vertex_data, converted_edge_data)
end

GraphsExtensions.convert_vertextype(::Type{V}, graph::DataGraph{V}) where {V} = graph
function GraphsExtensions.convert_vertextype(vertextype::Type, graph::DataGraph)
    return DataGraph{vertextype}(graph)
end

# TODO: implement generic version in terms of `set_underlying_graph_type`.
function GraphsExtensions.directed_graph_type(graph_type::Type{<:DataGraph})
    return DataGraph{
        vertextype(graph_type),
        vertex_data_eltype(graph_type),
        edgetype(graph_type),
        directed_graph_type(underlying_graph_type(graph_type)),
        edgetype(graph_type),
    }
end

# TODO: define VertexDataGraph, a graph with only data on the
# vertices, and EdgeDataGraph, a graph with only data on the edges.
# TODO: Constrain `E<:AbstractEdge`.
# TODO: Use https://github.com/vtjnash/ComputedFieldTypes.jl to
# automatically determine `E` from `G` from `edgetype(G)`
# and `V` from `G` as `vertextype(G)`.
struct DataGraph{V,VD,ED,G<:AbstractGraph,E<:AbstractEdge} <: AbstractDataGraph{V,VD,ED}
  underlying_graph::G
  vertex_data::Dictionary{V,VD}
  edge_data::Dictionary{E,ED}
  function DataGraph{V,VD,ED,G,E}(
    underlying_graph::G, vertex_data::Dictionary{V,VD}, edge_data::Dictionary{E,ED}
  ) where {V,VD,ED,G<:AbstractGraph,E<:AbstractEdge}
    @assert vertextype(underlying_graph) == V
    @assert edgetype(underlying_graph) == E
    return new{V,VD,ED,G,E}(underlying_graph, vertex_data, edge_data)
  end
end
underlying_graph_type(G::Type{<:DataGraph}) = fieldtype(G, :underlying_graph)
# TODO: rename vertex_data_eltype
vertex_data_type(G::Type{<:DataGraph}) = eltype(fieldtype(G, :vertex_data))
# TODO: rename edge_data_eltype
edge_data_type(G::Type{<:DataGraph}) = eltype(fieldtype(G, :edge_data))
underlying_graph(graph::DataGraph) = getfield(graph, :underlying_graph)
vertex_data(graph::DataGraph) = getfield(graph, :vertex_data)
edge_data(graph::DataGraph) = getfield(graph, :edge_data)

# TODO: Is this needed?
underlying_graph_type(graph::DataGraph) = typeof(underlying_graph(graph))
# TODO: Is this needed?
is_directed(G::Type{<:DataGraph}) = is_directed(underlying_graph_type(G))

# TODO: Implement in terms of `set_underlying_graph`, `set_vertex_data`, etc.
# TODO: Use `https://github.com/JuliaObjects/Accessors.jl`?
function copy(graph::DataGraph)
  # Need to manually copy the keys of Dictionaries, see:
  # https://github.com/andyferris/Dictionaries.jl/issues/98
  return DataGraph(
    copy(underlying_graph(graph)),
    copy_keys_values(vertex_data(graph)),
    copy_keys_values(edge_data(graph)),
  )
end

#
# Constructors
#

function DataGraph{V,VD,ED,G,E}(
  underlying_graph::AbstractGraph=G(),
  vertex_data::Dictionary=Dictionary{V,VD}(),
  edge_data::Dictionary=Dictionary{E,ED}(),
) where {V,VD,ED,G,E}
  return DataGraph{V,VD,ED,G,E}(
    convert(G, underlying_graph),
    convert(Dictionary{V,VD}, vertex_data),
    convert(Dictionary{E,ED}, edge_data),
  )
end

function DataGraph{V,VD,ED}(
  underlying_graph::AbstractGraph{V},
  vertex_data::Dictionary=Dictionary{V,VD}(),
  edge_data::Dictionary=Dictionary{edgetype(underlying_graph),ED}(),
) where {V,VD,ED}
  G = typeof(underlying_graph)
  E = edgetype(underlying_graph)
  return DataGraph{V,VD,ED,G,E}(underlying_graph, vertex_data, edge_data)
end

function DataGraph{V,VD,ED}(
  underlying_graph::AbstractGraph=NamedGraph{V}(),
  vertex_data::Dictionary=Dictionary{V,VD}(),
  edge_data::Dictionary=Dictionary{edgetype(underlying_graph),ED}(),
) where {V,VD,ED}
  return DataGraph{V,VD,ED}(convert_vertextype(V, underlying_graph), vertex_data, edge_data)
end

function DataGraph{<:Any,VD,ED}(
  underlying_graph::AbstractGraph,
  vertex_data::Dictionary=Dictionary{vertextype(underlying_graph),VD}(),
  edge_data::Dictionary=Dictionary{edgetype(underlying_graph),ED}(),
) where {VD,ED}
  V = vertextype(underlying_graph)
  return DataGraph{V,VD,ED}(underlying_graph, vertex_data, edge_data)
end

function DataGraph{V,VD}(
  underlying_graph::AbstractGraph=NamedGraph{V}(),
  vertex_data::Dictionary=Dictionary{V,VD}(),
  edge_data::Dictionary=Dictionary{edgetype(underlying_graph),Any}(),
) where {V,VD}
  ED = eltype(edge_data)
  return DataGraph{V,VD,ED}(underlying_graph, vertex_data, edge_data)
end

function DataGraph{<:Any,VD}(
  underlying_graph::AbstractGraph,
  vertex_data::Dictionary=Dictionary{vertextype(underlying_graph),VD}(),
  edge_data::Dictionary=Dictionary{edgetype(underlying_graph),Any}(),
) where {VD}
  V = vertextype(underlying_graph)
  ED = eltype(edge_data)
  return DataGraph{V,VD,ED}(underlying_graph, vertex_data, edge_data)
end

function DataGraph{V}(
  underlying_graph::AbstractGraph=NamedGraph{V}(),
  vertex_data::Dictionary=Dictionary{V,Any}(),
  edge_data::Dictionary=Dictionary{edgetype(underlying_graph),Any}(),
) where {V}
  VD = eltype(vertex_data)
  ED = eltype(edge_data)
  return DataGraph{V,VD,ED}(underlying_graph, vertex_data, edge_data)
end

function DataGraph(
  underlying_graph::AbstractGraph=NamedGraph{Any}(),
  vertex_data::Dictionary=Dictionary{vertextype(underlying_graph),Any}(),
  edge_data::Dictionary=Dictionary{edgetype(underlying_graph),Any}(),
)
  V = vertextype(underlying_graph)
  return DataGraph{V}(underlying_graph, vertex_data, edge_data)
end

#
# Type interface
#

function DataGraph{V}(underlying_graph::AbstractGraph, VD::Type, ED::Type=Any) where {V}
  return DataGraph{V,VD,ED}(underlying_graph)
end

function DataGraph(underlying_graph::AbstractGraph, VD::Type, ED::Type=Any)
  V = vertextype(underlying_graph)
  return DataGraph{V,VD,ED}(underlying_graph)
end

#
# Convenience constructors for simple graphs
#

function DataGraph{V,VD,ED,G,E}(nv::Integer, args...) where {V,VD,ED,G,E}
  return DataGraph{V,VD,ED,G,E}(SimpleGraph(nv), args...)
end
function DataGraph{V,VD,ED}(nv::Integer, args...) where {V,VD,ED}
  return DataGraph{V,VD,ED}(SimpleGraph(nv), args...)
end
function DataGraph{<:Any,VD,ED}(nv::Integer, args...) where {VD,ED}
  return DataGraph{<:Any,VD,ED}(SimpleGraph(nv), args...)
end
function DataGraph{V,VD}(nv::Integer, args...) where {V,VD}
  return DataGraph{V,VD}(SimpleGraph(nv), args...)
end
function DataGraph{<:Any,VD}(nv::Integer, args...) where {VD}
  return DataGraph{<:Any,VD}(SimpleGraph(nv), args...)
end
DataGraph{V}(nv::Integer, args...) where {V} = DataGraph{V}(SimpleGraph(nv), args...)
DataGraph(nv::Integer, args...) = DataGraph(SimpleGraph(nv), args...)

# Type conversions
DataGraph{V,VD,ED,G}(graph::DataGraph{V,VD,ED,G}) where {V,VD,ED,G} = copy(graph)
DataGraph{V,VD,ED}(graph::DataGraph{V,VD,ED}) where {V,VD,ED} = copy(graph)
DataGraph{V,VD}(graph::DataGraph{V,VD}) where {V,VD} = copy(graph)
DataGraph{V}(graph::DataGraph{V}) where {V} = copy(graph)
function DataGraph{V}(graph::DataGraph) where {V}
  E = convert_vertextype(V, edgetype(graph))
  # TODO: Make sure this properly copies
  converted_underlying_graph = convert_vertextype(V, underlying_graph(graph))
  converted_vertex_data = Dictionary{V}(vertex_data(graph))
  converted_edge_data = Dictionary{E}(edge_data(graph))
  return DataGraph{V}(
    converted_underlying_graph, converted_vertex_data, converted_edge_data
  )
end

convert_vertextype(::Type{V}, graph::DataGraph{V}) where {V} = graph
function convert_vertextype(V::Type, graph::DataGraph)
  return DataGraph{V}(graph)
end

# TODO: implement generic version in terms of `set_underlying_graph_type`
function directed_graph(G::Type{<:DataGraph})
  V = vertextype(G)
  VD = vertex_data_type(G)
  E = edgetype(G)
  ED = edge_data_type(G)
  UG = underlying_graph_type(G)
  return DataGraph{V,VD,ED,directed_graph(UG),E}
end

# TODO: define VertexDataGraph, a graph with only data on the
# vertices, and EdgeDataGraph, a graph with only data on the edges.
# TODO: Constrain `E<:AbstractEdge`.
# TODO: Use https://github.com/vtjnash/ComputedFieldTypes.jl to
# automatically determine `E` from `G` from `edgetype(G)`
# and `V` from `G` as `vertextype(G)`.
struct DataGraph{V,VD,ED,G<:AbstractGraph,E} <: AbstractDataGraph{V,VD,ED}
  underlying_graph::G
  vertex_data::Dictionary{V,VD}
  edge_data::Dictionary{E,ED}
  function DataGraph{V,VD,ED,G,E}(
    underlying_graph::G, vertex_data::Dictionary{V,VD}, edge_data::Dictionary{E,ED}
  ) where {V,VD,ED,G<:AbstractGraph,E}
    @assert vertextype(underlying_graph) == V
    return new{V,VD,ED,G,E}(underlying_graph, vertex_data, edge_data)
  end
end
underlying_graph(graph::DataGraph) = graph.underlying_graph
underlying_graph_type(::Type{<:DataGraph{V,VD,ED,G}}) where {V,VD,ED,G} = G
vertex_data(graph::DataGraph) = graph.vertex_data
vertex_data_type(::Type{<:DataGraph{V,VD}}) where {V,VD} = VD
edge_data(graph::DataGraph) = graph.edge_data
edge_data_type(::Type{<:DataGraph{V,VD,ED}}) where {V,VD,ED} = ED

# TODO: Is this needed?
underlying_graph_type(graph::DataGraph) = typeof(underlying_graph(graph))
# TODO: Is this needed?
is_directed(::Type{<:DataGraph{V,VD,ED,G}}) where {V,VD,ED,G} = is_directed(G)

# TODO: implement generic version in terms of `set_underlying_graph_type`
function directed_graph(G::Type{<:DataGraph})
  V = vertextype(G)
  VD = vertex_data_type(G)
  E = edgetype(G)
  ED = edge_data_type(G)
  UG = underlying_graph_type(G)
  return DataGraph{V,VD,ED,directed_graph(UG),E}
end

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

# Empty construct, used in `Graphs.zero`
function DataGraph{V,VD,ED,G,E}() where {V,VD,ED,G<:AbstractGraph,E<:AbstractEdge}
  return DataGraph{V,VD,ED,G,E}(G())
end

function DataGraph{VD,ED}(
  underlying_graph::AbstractGraph, vertex_data::Dictionary, edge_data::Dictionary
) where {VD,ED}
  G = typeof(underlying_graph)
  V = vertextype(underlying_graph)
  E = edgetype(underlying_graph)
  return DataGraph{V,VD,ED,G,E}(
    underlying_graph,
    convert(Dictionary{V,VD}, vertex_data),
    convert(Dictionary{E,ED}, edge_data),
  )
end

function DataGraph(
  underlying_graph::AbstractGraph, vertex_data::Dictionary, edge_data::Dictionary
)
  return DataGraph{eltype(vertex_data),eltype(edge_data)}(
    underlying_graph, vertex_data, edge_data
  )
end

function DataGraph{V,VD,ED,G,E}(underlying_graph::AbstractGraph) where {V,VD,ED,G,E}
  vertex_data = Dictionary{V,VD}()
  edge_data = Dictionary{E,ED}()
  return DataGraph{V,VD,ED,G,E}(underlying_graph, vertex_data, edge_data)
end

function DataGraph{V,VD,ED}(underlying_graph::AbstractGraph{V}) where {V,VD,ED}
  @assert vertextype(underlying_graph) == V
  G = typeof(underlying_graph)
  E = edgetype(underlying_graph)
  return DataGraph{V,VD,ED,G,E}(underlying_graph)
end

# TODO: Move to Graphs.jl
convert_vertextype(::Type{V}, graph::AbstractGraph{V}) where {V} = graph
function convert_vertextype(V::Type, graph::AbstractGraph)
  return not_implemented()
end
# TODO: Move to NamedGraphs.jl
function convert_vertextype(V::Type, graph::NamedGraphs.GenericNamedGraph)
  return NamedGraphs.GenericNamedGraph(
    NamedGraphs.parent_graph(graph), convert(Vector{V}, vertices(graph))
  )
end

function DataGraph{V,VD,ED}(underlying_graph::AbstractGraph) where {V,VD,ED}
  return DataGraph{V,VD,ED}(convert_vertextype(V, underlying_graph))
end

function DataGraph{VD,ED}(underlying_graph::AbstractGraph) where {VD,ED}
  V = vertextype(underlying_graph)
  G = typeof(underlying_graph)
  E = edgetype(underlying_graph)
  return DataGraph{V,VD,ED}(underlying_graph)
end

DataGraph(underlying_graph::AbstractGraph) = DataGraph{Any,Any}(underlying_graph)
function DataGraph{VD}(underlying_graph::AbstractGraph) where {VD}
  return DataGraph{VD,Any}(underlying_graph)
end

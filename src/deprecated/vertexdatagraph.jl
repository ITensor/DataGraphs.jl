# TODO: define VertexDataGraph, a graph with only data on the
# vertices, and EdgeDataGraph, a graph with only data on the edges.
struct VertexDataGraph{V,VD,G<:AbstractGraph} <: AbstractDataGraph{V,VD,Any}
  underlying_graph::G
  vertex_data::Dictionary{V,VD}
end
underlying_graph(graph::VertexDataGraph) = graph.underlying_graph
underlying_graph_type(::Type{<:VertexDataGraph{V,VD,ED,G}}) where {V,VD,ED,G} = G
vertex_data(graph::VertexDataGraph) = graph.vertex_data
vertex_data_type(::Type{<:VertexDataGraph{V,VD}}) where {V,VD} = VD
edge_data(graph::VertexDataGraph) = error("No edge data")
edge_data_type(::Type{<:VertexDataGraph{V,VD,ED}}) where {V,VD,ED} = error("No edge data")

# TODO: implement generic version in terms of `set_underlying_graph_type`
function directed_graph(G::Type{<:VertexDataGraph})
  V = vertextype(G)
  VD = vertex_data_type(G)
  UG = underlying_graph_type(G)
  return VertexDataGraph{V,VD,directed_graph(UG)}
end

# TODO: Implement in terms of `set_underlying_graph`, `set_vertex_data`, etc.
# TODO: Use `https://github.com/JuliaObjects/Accessors.jl`?
function copy(graph::VertexDataGraph)
  return VertexDataGraph(
    copy(underlying_graph(graph)), copy(vertex_data(graph))
  )
end

function VertexDataGraph{VD}(
  underlying_graph::AbstractGraph,
  vertex_data::Dictionary,
) where {VD}
  G = typeof(underlying_graph)
  V = keytype(vertex_data)
  return VertexDataGraph{V,VD,G}(underlying_graph, vertex_data)
end

# TODO: Delete, use default values for `vertex_data` in other constructor
function VertexDataGraph{V,VD,G}(underlying_graph::AbstractGraph) where {V,VD,G}
  vertex_data = Dictionary{V,VD}()
  return VertexDataGraph{V,VD,G}(underlying_graph, vertex_data)
end

# TODO: Delete, use default values for `vertex_data` in other constructor
function VertexDataGraph{VD}(underlying_graph::AbstractGraph) where {VD}
  V = vertextype(underlying_graph)
  G = typeof(underlying_graph)
  return VertexDataGraph{V,VD,G}(underlying_graph)
end

VertexDataGraph(underlying_graph::AbstractGraph) = VertexDataGraph{Any,Any}(underlying_graph)
function VertexDataGraph{VD}(underlying_graph::AbstractGraph) where {VD}
  return VertexDataGraph{VD,Any}(underlying_graph)
end

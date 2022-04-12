# TODO: define VertexDataGraph, a graph with only data on the
# vertices, and EdgeDataGraph, a graph with only data on the edges.
struct DataGraph{VD,ED,V,E,G<:AbstractGraph} <: AbstractDataGraph{VD,ED,V,E}
  underlying_graph::G
  vertex_data::Dictionary{V,VD}
  edge_data::Dictionary{E,ED}
end
underlying_graph(graph::DataGraph) = graph.underlying_graph
vertex_data(graph::DataGraph) = graph.vertex_data
edge_data(graph::DataGraph) = graph.edge_data

copy(graph::DataGraph) = DataGraph(copy(underlying_graph(graph)), copy(vertex_data(graph)), copy(edge_data(graph)))

function DataGraph{VD,ED}(
  underlying_graph::AbstractGraph,
  vertex_data::Dictionary{V,VD},
  edge_data::Dictionary{E,ED},
) where {VD,ED,V,E}
  G = typeof(underlying_graph)
  return DataGraph{VD,ED,V,E,G}(underlying_graph, vertex_data, edge_data)
end

function DataGraph{VD,ED}(
  underlying_graph::AbstractGraph,
) where {VD,ED}
  V = eltype(underlying_graph)
  E = edgetype(underlying_graph)
  vertex_data = Dictionary{V,VD}()
  edge_data = Dictionary{E,ED}()
  return DataGraph{VD,ED}(underlying_graph, vertex_data, edge_data)
end

DataGraph(underlying_graph::AbstractGraph) = DataGraph{Any,Any}(underlying_graph)
DataGraph{VD}(underlying_graph::AbstractGraph) where {VD} = DataGraph{VD,Any}(underlying_graph)

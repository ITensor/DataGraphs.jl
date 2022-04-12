# TODO: define VertexMultiDimDataGraph, a graph with only data on the
# vertices, and EdgeMultiDimDataGraph, a graph with only data on the edges.
struct MultiDimDataGraph{VD,ED,V,E,G<:AbstractGraph} <: AbstractDataGraph{VD,ED,V,E}
  underlying_graph::G
  vertex_data::MultiDimDictionary{V,VD}
  edge_data::Dictionary{E,ED}
end
underlying_graph(graph::MultiDimDataGraph) = graph.underlying_graph
vertex_data(graph::MultiDimDataGraph) = graph.vertex_data
edge_data(graph::MultiDimDataGraph) = graph.edge_data

copy(graph::MultiDimDataGraph) = MultiDimDataGraph(copy(underlying_graph(graph)), copy(vertex_data(graph)), copy(edge_data(graph)))

function MultiDimDataGraph{VD,ED}(
  underlying_graph::AbstractGraph,
  vertex_data::MultiDimDictionary{V,VD},
  edge_data::Dictionary{E,ED},
) where {VD,ED,V,E}
  G = typeof(underlying_graph)
  return MultiDimDataGraph{VD,ED,V,E,G}(underlying_graph, vertex_data, edge_data)
end

function MultiDimDataGraph{VD,ED}(
  underlying_graph::AbstractGraph,
) where {VD,ED}
  V = eltype(underlying_graph)
  E = edgetype(underlying_graph)
  vertex_data = MultiDimDictionary{V,VD}()
  edge_data = Dictionary{E,ED}()
  return MultiDimDataGraph{VD,ED}(underlying_graph, vertex_data, edge_data)
end

MultiDimDataGraph(underlying_graph::AbstractGraph) = MultiDimDataGraph{Any,Any}(underlying_graph)
MultiDimDataGraph{VD}(underlying_graph::AbstractGraph) where {VD} = MultiDimDataGraph{VD,Any}(underlying_graph)

#
# Specializations for MultiDimDataGraph
#

function is_vertex_or_edge(graph::MultiDimDataGraph, v_or_e)
  (tuple_convert(v_or_e) isa eltype(graph)) && return IsVertex()
  return error("$v_or_e doesn't represent a vertex or an edge for graph:\n$graph.")
end

# Ambiguity error with AbstractGraph version
is_vertex_or_edge(graph::MultiDimDataGraph, ::AbstractEdge) = IsEdge()

# Ambiguity error with AbstractGraph version
is_vertex_or_edge(graph::MultiDimDataGraph, ::Pair) = IsEdge()

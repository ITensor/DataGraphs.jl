# TODO: define VertexNamedDimDataGraph, a graph with only data on the
# vertices, and EdgeNamedDimDataGraph, a graph with only data on the edges.
struct NamedDimDataGraph{VD,ED,V,E,G<:AbstractGraph} <: AbstractDataGraph{VD,ED,V,E}
  underlying_graph::G
  vertex_data::MultiDimDictionary{V,VD}
  edge_data::Dictionary{E,ED}
end
underlying_graph(graph::NamedDimDataGraph) = graph.underlying_graph
vertex_data(graph::NamedDimDataGraph) = graph.vertex_data
edge_data(graph::NamedDimDataGraph) = graph.edge_data

function copy(graph::NamedDimDataGraph)
  return NamedDimDataGraph(
    copy(underlying_graph(graph)), copy(vertex_data(graph)), copy(edge_data(graph))
  )
end

function NamedDimDataGraph{VD,ED}(
  underlying_graph::AbstractGraph,
  vertex_data::MultiDimDictionary{V,VD},
  edge_data::Dictionary{E,ED},
) where {VD,ED,V,E}
  G = typeof(underlying_graph)
  return NamedDimDataGraph{VD,ED,V,E,G}(underlying_graph, vertex_data, edge_data)
end

function NamedDimDataGraph{VD,ED}(underlying_graph::AbstractGraph) where {VD,ED}
  V = eltype(underlying_graph)
  E = edgetype(underlying_graph)
  vertex_data = MultiDimDictionary{V,VD}()
  edge_data = Dictionary{E,ED}()
  return NamedDimDataGraph{VD,ED}(underlying_graph, vertex_data, edge_data)
end

function NamedDimDataGraph(underlying_graph::AbstractGraph)
  return NamedDimDataGraph{Any,Any}(underlying_graph)
end
function NamedDimDataGraph{VD}(underlying_graph::AbstractGraph) where {VD}
  return NamedDimDataGraph{VD,Any}(underlying_graph)
end

#
# Specializations for NamedDimDataGraph
#

function is_vertex_or_edge(graph::NamedDimDataGraph, v_or_e)
  (tuple_convert(v_or_e) isa eltype(graph)) && return IsVertex()
  return error("$v_or_e doesn't represent a vertex or an edge for graph:\n$graph.")
end

# Ambiguity error with AbstractGraph version
is_vertex_or_edge(graph::NamedDimDataGraph, ::AbstractEdge) = IsEdge()

# Ambiguity error with AbstractGraph version
is_vertex_or_edge(graph::NamedDimDataGraph, ::Pair) = IsEdge()

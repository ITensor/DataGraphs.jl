abstract type AbstractNamedDimDataGraph{VD,ED,V,E} <: AbstractDataGraph{VD,ED,V,E} end

#
# Specializations for AbstractNamedDimDataGraph
#

## function IndexType(graph::AbstractNamedDimDataGraph, v_or_e)
##   (tuple_convert(v_or_e) isa eltype(graph)) && return VertexIndex()
##   return error("$v_or_e doesn't represent a vertex or an edge for graph:\n$graph.")
## end

ElementIndex_to_VertexIndex(x) = x
ElementIndex_to_VertexIndex(::ElementIndex) = VertexIndex()

IndexType(::AbstractNamedDimDataGraph, I...) = ElementIndex_to_VertexIndex(IndexType(I...))

# Ambiguity error with AbstractGraph version
IndexType(::AbstractNamedDimDataGraph{VD,ED,V}, ::V) where {VD,ED,V} = VertexIndex()

# Ambiguity error with AbstractGraph version
IndexType(::AbstractNamedDimDataGraph, ::AbstractEdge) = EdgeIndex()

# Ambiguity error with AbstractGraph version
IndexType(::AbstractNamedDimDataGraph, ::Pair) = EdgeIndex()

# TODO: define VertexNamedDimDataGraph, a graph with only data on the
# vertices, and EdgeNamedDimDataGraph, a graph with only data on the edges.
struct NamedDimDataGraph{VD,ED,V,E,G<:AbstractGraph} <: AbstractNamedDimDataGraph{VD,ED,V,E}
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

function getindex(::SliceIndex, graph::NamedDimDataGraph, index...)
  underlying_subgraph = getindex(underlying_graph(graph), index...)
  subvertices = vertices(underlying_subgraph)
  subvertex_data = vertex_data(graph)[subvertices]
  subedge_data = filter(e -> src(e) ∈ subvertices && dst(e) ∈ subvertices, keys(edge_data(graph)))
  return NamedDimDataGraph(underlying_subgraph, subvertex_data, getindices(edge_data(graph), subedge_data))
end

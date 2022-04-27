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

function getindex(::SliceIndex, graph::AbstractNamedDimDataGraph, index...)
  underlying_subgraph = getindex(underlying_graph(graph), index...)
  subvertices = vertices(underlying_subgraph)
  subvertex_data = vertex_data(graph)[subvertices]
  subedge_data_indices = filter(e -> src(e) ∈ subvertices && dst(e) ∈ subvertices, keys(edge_data(graph)))
  subedge_data = getindices(edge_data(graph), subedge_data_indices)
  return typeof(graph)(underlying_subgraph, subvertex_data, subedge_data)
end

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

function is_directed(::Type{<:NamedDimDataGraph{VD,ED,V,E,G}}) where {VD,ED,V,E,G}
  return is_directed(G)
end

function copy(graph::NamedDimDataGraph)
  # Need to use deepcopy of Dictionaries, see:
  # https://github.com/andyferris/Dictionaries.jl/issues/98
  return NamedDimDataGraph(
    copy(underlying_graph(graph)), deepcopy(vertex_data(graph)), deepcopy(edge_data(graph))
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

function NamedDimDataGraph{VD,ED}() where {VD,ED}
  return NamedDimDataGraph{VD,ED}(NamedDimGraph())
end

function NamedDimDataGraph{VD}() where {VD}
  return NamedDimDataGraph{VD,Any}(NamedDimGraph())
end

function NamedDimDataGraph()
  return NamedDimDataGraph{Any,Any}(NamedDimGraph())
end

function NamedDimDataGraph{VD,ED}(underlying_graph::NamedDimGraph) where {VD,ED}
  V = eltype(underlying_graph)
  E = edgetype(underlying_graph)
  vertex_data = MultiDimDictionary{V,VD}()
  edge_data = Dictionary{E,ED}()
  return NamedDimDataGraph{VD,ED}(underlying_graph, vertex_data, edge_data)
end

function NamedDimDataGraph{VD}(underlying_graph::NamedDimGraph) where {VD}
  return NamedDimDataGraph{VD,Any}(underlying_graph)
end

function NamedDimDataGraph(underlying_graph::NamedDimGraph)
  return NamedDimDataGraph{Any,Any}(underlying_graph)
end

function NamedDimDataGraph{VD,ED}(underlying_graph::Graph; kwargs...) where {VD,ED}
  return NamedDimDataGraph{VD,ED}(NamedDimGraph(underlying_graph; kwargs...))
end

function NamedDimDataGraph{VD}(underlying_graph::Graph; kwargs...) where {VD}
  return NamedDimDataGraph{VD}(NamedDimGraph(underlying_graph; kwargs...))
end

function NamedDimDataGraph(underlying_graph::Graph; kwargs...)
  return NamedDimDataGraph(NamedDimGraph(underlying_graph; kwargs...))
end

function hvncat(
  dim::Int, graph1::NamedDimDataGraph, graph2::NamedDimDataGraph; new_dim_names=(1, 2)
)
  # Concatenate the underlying graph
  new_underlying_graph = hvncat(dim, underlying_graph(graph1), underlying_graph(graph2); new_dim_names)

  # The new vertices of the graph.
  # This can introduce new dimensions, shift values, etc.
  new_vertices = vertices(new_underlying_graph)

  # Map the vertices of the vertex data to the new vertices (for the first input graph)
  map_vertices1 = Dictionary(vertices(graph1), new_vertices[1:nv(graph1)])
  new_vertices1 = getindices(map_vertices1, keys(vertex_data(graph1)))
  new_vertex_data1 = MultiDimDictionary(new_vertices1, vertex_data(graph1))

  # Map the vertices of the vertex data to the new vertices (for the second input graph)
  map_vertices2 = Dictionary(vertices(graph2), new_vertices[(nv(graph1) + 1):end])
  new_vertices2 = getindices(map_vertices2, keys(vertex_data(graph2)))
  new_vertex_data2 = MultiDimDictionary(new_vertices2, vertex_data(graph2))

  new_vertex_data = merge(new_vertex_data1, new_vertex_data2)

  # The new edges of the graph.
  # This can introduce new dimensions, shift values, etc.
  new_edges = edges(new_underlying_graph)

  # Map the edges of the edge data to the new vertices (for the first input graph)
  map_edges1_out = Dictionary(edges(graph1), new_edges[1:ne(graph1)])
  map_edges1_in = Dictionary(reverse.(keys(map_edges1_out)), reverse.(map_edges1_out))
  map_edges1 = merge(map_edges1_out, map_edges1_in)
  new_edges1 = getindices(map_edges1, keys(edge_data(graph1)))
  new_edge_data1 = Dictionary(new_edges1, edge_data(graph1))

  # Map the edges of the edge data to the new vertices (for the second input graph)
  map_edges2_out = Dictionary(edges(graph2), new_edges[(ne(graph1) + 1):end])
  map_edges2_in = Dictionary(reverse.(keys(map_edges2_out)), reverse.(map_edges2_out))
  map_edges2 = merge(map_edges2_out, map_edges2_in)
  new_edges2 = getindices(map_edges2, keys(edge_data(graph2)))
  new_edge_data2 = Dictionary(new_edges2, edge_data(graph2))

  # convert is needed because type information is lost by Dictionaries.jl
  new_edge_data = convert(typeof(edge_data(graph1)), merge(new_edge_data1, new_edge_data2))

  return NamedDimDataGraph(new_underlying_graph, new_vertex_data, new_edge_data)
end

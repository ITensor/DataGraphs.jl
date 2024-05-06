using Dictionaries: set!, unset!
using Graphs:
  Graphs, AbstractEdge, AbstractGraph, IsDirected, add_edge!, edges, ne, nv, vertices
using NamedGraphs.GraphsExtensions: GraphsExtensions, incident_edges, vertextype
using NamedGraphs.SimilarType: similar_type
using SimpleTraits: SimpleTraits, Not, @traitfn

abstract type AbstractDataGraph{V,VD,ED} <: AbstractGraph{V} end

# Minimal interface
# TODO: Define for `AbstractGraph` as a `DataGraphInterface`.
underlying_graph(::AbstractDataGraph) = not_implemented()
underlying_graph_type(::Type{<:AbstractDataGraph}) = not_implemented()
vertex_data(::AbstractDataGraph) = not_implemented()
vertex_data_eltype(::Type{<:AbstractDataGraph}) = not_implemented()
edge_data(::AbstractDataGraph) = not_implemented()
edge_data_eltype(::Type{<:AbstractDataGraph}) = not_implemented()

# Derived interface
function Graphs.edgetype(graph_type::Type{<:AbstractDataGraph})
  return Graphs.edgetype(underlying_graph_type(graph_type))
end
function Graphs.is_directed(graph_type::Type{<:AbstractDataGraph})
  return Graphs.is_directed(underlying_graph_type(graph_type))
end
underlying_graph_type(graph::AbstractDataGraph) = typeof(underlying_graph(graph))
vertex_data_eltype(graph::AbstractDataGraph) = eltype(vertex_data(graph))
edge_data_eltype(graph::AbstractDataGraph) = eltype(edge_data(graph))

# TODO: delete, defined for AbstractGraph{V}?
function GraphsExtensions.vertextype(graph_type::Type{<:AbstractDataGraph})
  return vertextype(underlying_graph_type(graph_type))
end
GraphsExtensions.vertextype(graph::AbstractDataGraph) = vertextype(typeof(graph))

Base.zero(graph_type::Type{<:AbstractDataGraph}) = graph_type()

# Graphs overloads
for f in [
  :(Graphs.a_star),
  :(Graphs.add_edge!),
  :(Graphs.add_vertex!),
  :(Graphs.adjacency_matrix),
  :(Graphs.bellman_ford_shortest_paths),
  :(Graphs.bfs_parents),
  :(Graphs.bfs_tree),
  :(Graphs.boruvka_mst),
  :(Graphs.center),
  :(Graphs.common_neighbors),
  :(Graphs.connected_components),
  :(Graphs.degree),
  :(Graphs.degree_histogram),
  :(Graphs.desopo_pape_shortest_paths),
  :(Graphs.dfs_parents),
  :(Graphs.dfs_tree),
  :(Graphs.diameter),
  :(Graphs.dijkstra_shortest_paths),
  :(Graphs.eccentricity),
  :(Graphs.edges),
  :(Graphs.edgetype),
  :(Graphs.eltype),
  :(Graphs.enumerate_paths),
  :(Graphs.floyd_warshall_shortest_paths),
  :(Graphs.has_edge),
  :(Graphs.has_path),
  :(Graphs.has_vertex),
  :(Graphs.inneighbors),
  :(Graphs.is_connected),
  :(Graphs.is_cyclic),
  :(Graphs.is_directed),
  :(Graphs.is_strongly_connected),
  :(Graphs.is_weakly_connected),
  :(Graphs.mincut),
  :(Graphs.ne),
  :(Graphs.neighbors),
  :(Graphs.neighborhood),
  :(Graphs.neighborhood_dists),
  :(Graphs.johnson_shortest_paths),
  :(Graphs.spfa_shortest_paths),
  :(Graphs.yen_k_shortest_paths),
  :(Graphs.kruskal_mst),
  :(Graphs.prim_mst),
  :(Graphs.nv),
  :(Graphs.outneighbors),
  :(Graphs.periphery),
  :(Graphs.radius),
  :(Graphs.steiner_tree),
  :(Graphs.topological_sort_by_dfs),
  :(Graphs.tree),
  :(Graphs.vertices),
  :(GraphsExtensions.boundary_edges),
  :(GraphsExtensions.boundary_vertices),
  :(GraphsExtensions.eccentricities),
  :(GraphsExtensions.inner_boundary_vertices),
  :(GraphsExtensions.mincut_partitions),
  :(GraphsExtensions.outer_boundary_vertices),
  :(GraphsExtensions.symrcm_perm),
  :(GraphsExtensions.symrcm_permute),
]
  @eval begin
    function $f(graph::AbstractDataGraph, args...; kwargs...)
      return $f(underlying_graph(graph), args...; kwargs...)
    end
  end
end

# Fix for ambiguity error with `AbstractGraph` version
function Graphs.degree(graph::AbstractDataGraph, vertex::Integer)
  return Graphs.degree(underlying_graph(graph), vertex)
end

# Fix for ambiguity error with `AbstractGraph` version
function Graphs.dijkstra_shortest_paths(
  graph::AbstractDataGraph, vertices::Vector{<:Integer}
)
  return Graphs.dijkstra_shortest_paths(underlying_graph(graph), vertices)
end

# Fix for ambiguity error with `AbstractGraph` version
function Graphs.eccentricity(graph::AbstractDataGraph, distmx::AbstractMatrix)
  return Graphs.eccentricity(underlying_graph(graph), distmx)
end

# Fix for ambiguity error with `AbstractGraph` version
function indegree(graph::AbstractDataGraph, vertex::Integer)
  return indegree(underlying_graph(graph), vertex)
end

# Fix for ambiguity error with `AbstractGraph` version
function outdegree(graph::AbstractDataGraph, vertex::Integer)
  return outdegree(underlying_graph(graph), vertex)
end

@traitfn GraphsExtensions.directed_graph(graph::AbstractDataGraph::IsDirected) = graph

@traitfn function GraphsExtensions.directed_graph(graph::AbstractDataGraph::(!IsDirected))
  digraph = directed_graph(typeof(graph))(directed_graph(underlying_graph(graph)))
  for v in vertices(graph)
    # TODO: Only loop over `keys(vertex_data(graph))`
    if isassigned(graph, v)
      digraph[v] = graph[v]
    end
  end
  for e in edges(graph)
    # TODO: Only loop over `keys(edge_data(graph))`
    # TODO: Are these needed?
    add_edge!(digraph, e)
    add_edge!(digraph, reverse(e))
    if isassigned(graph, e)
      digraph[e] = graph[e]
      digraph[reverse(e)] = reverse_data_direction(graph, graph[e])
    end
  end
  return digraph
end

function Base.reverse(graph::AbstractDataGraph)
  reversed_graph = typeof(graph)(reverse(underlying_graph(graph)))
  for v in vertices(graph)
    if isassigned(graph, v)
      reversed_graph[v] = graph[v]
    end
  end
  for e in edges(graph)
    if isassigned(graph, e)
      reversed_graph[reverse(e)] = graph[e]
    end
  end
  return reversed_graph
end

function Graphs.merge_vertices(
  graph::AbstractDataGraph,
  merge_vertices;
  merge_data=(x, y) -> y,
  merge_vertex_data=merge_data,
  merge_edge_data=merge_data,
  kwargs...,
)
  underlying_merged_graph = Graphs.merge_vertices(underlying_graph(graph); kwargs...)
  return not_implemented()
end

function Graphs.merge_vertices!(
  graph::AbstractDataGraph,
  merge_vertices;
  merge_data=(x, y) -> y,
  merge_vertex_data=merge_data,
  merge_edge_data=merge_data,
  kwargs...,
)
  underlying_merged_graph = copy(underlying_graph(graph))
  Graphs.merge_vertices!(underlying_merged_graph; kwargs...)
  return not_implemented()
end

# Union the vertices and edges of the graphs and
# merge the vertex and edge metadata.
function Base.union(
  graph1::AbstractDataGraph,
  graph2::AbstractDataGraph;
  merge_data=(x, y) -> y,
  merge_vertex_data=merge_data,
  merge_edge_data=merge_data,
)
  underlying_graph_union = union(underlying_graph(graph1), underlying_graph(graph2))
  vertex_data_merge = mergewith(merge_vertex_data, vertex_data(graph1), vertex_data(graph2))
  edge_data_merge = mergewith(merge_edge_data, edge_data(graph1), edge_data(graph2))
  # TODO: Convert to `promote_type(typeof(graph1), typeof(graph2))`
  return _DataGraph(underlying_graph_union, vertex_data_merge, edge_data_merge)
end

function Base.union(
  graph1::AbstractDataGraph,
  graph2::AbstractDataGraph,
  graph3::AbstractDataGraph,
  graphs_tail::AbstractDataGraph...;
  kwargs...,
)
  return union(union(graph1, graph2; kwargs...), graph3, graphs_tail...; kwargs...)
end

function GraphsExtensions.rename_vertices(f::Function, graph::AbstractDataGraph)
  renamed_underlying_graph = GraphsExtensions.rename_vertices(f, underlying_graph(graph))
  # TODO: Base the ouput type on `typeof(graph)`, for example:
  # convert_vertextype(eltype(renamed_vertices), typeof(graph))(renamed_underlying_graph)
  renamed_graph = DataGraph(
    renamed_underlying_graph;
    vertex_data_eltype=vertex_data_eltype(graph),
    edge_data_eltype=edge_data_eltype(graph),
  )
  for v in keys(vertex_data(graph))
    renamed_graph[f(v)] = graph[v]
  end
  for e in keys(edge_data(graph))
    renamed_graph[GraphsExtensions.rename_vertices(f, e)] = graph[e]
  end
  return renamed_graph
end

function Graphs.rem_vertex!(graph::AbstractDataGraph, vertex)
  neighbor_edges = incident_edges(graph, vertex)
  # unset!(vertex_data(graph), to_vertex(graph, vertex...))
  unset!(vertex_data(graph), vertex)
  for neighbor_edge in neighbor_edges
    unset!(edge_data(graph), neighbor_edge)
  end
  Graphs.rem_vertex!(underlying_graph(graph), vertex)
  return graph
end

function Graphs.rem_edge!(graph::AbstractDataGraph, edge)
  unset!(edge_data(graph), edge)
  Graphs.rem_edge!(underlying_graph(graph), edge)
  return graph
end

# Fix ambiguity with:
# Graphs.neighbors(graph::AbstractGraph, v::Integer)
function Graphs.neighbors(graph::AbstractDataGraph, v::Integer)
  return Graphs.neighbors(underlying_graph(graph), v)
end

# Fix ambiguity with:
# Graphs.bfs_tree(graph::AbstractGraph, s::Integer; dir)
function Graphs.bfs_tree(graph::AbstractDataGraph, s::Integer; kwargs...)
  return Graphs.bfs_tree(underlying_graph(graph), s; kwargs...)
end

# Fix ambiguity with:
# Graphs.dfs_tree(graph::AbstractGraph, s::Integer; dir)
function Graphs.dfs_tree(graph::AbstractDataGraph, s::Integer; kwargs...)
  return Graphs.dfs_tree(underlying_graph(graph), s; kwargs...)
end

function map_vertex_data(f, graph::AbstractDataGraph; vertices=nothing)
  graph′ = copy(graph)
  vs = isnothing(vertices) ? Graphs.vertices(graph) : vertices
  for v in vs
    graph′[v] = f(graph[v])
  end
  return graph′
end

function map_edge_data(f, graph::AbstractDataGraph; edges=nothing)
  graph′ = copy(graph)
  es = isnothing(edges) ? Graphs.edges(graph) : edges
  for e in es
    if isassigned(graph, e)
      graph′[e] = f(graph[e])
    end
  end
  return graph′
end

function map_data(f, graph::AbstractDataGraph; vertices=nothing, edges=nothing)
  graph = map_vertex_data(f, graph; vertices)
  return map_edge_data(f, graph; edges)
end

function Base.getindex(graph::AbstractDataGraph, vertex)
  return vertex_data(graph)[vertex]
end

function Base.get(graph::AbstractDataGraph, vertex, default)
  return get(vertex_data(graph), vertex, default)
end

function Base.get!(graph::AbstractDataGraph, vertex, default)
  return get!(vertex_data(graph), vertex, default)
end

function Base.getindex(graph::AbstractDataGraph, edge::AbstractEdge)
  is_edge_arranged_ = is_edge_arranged(graph, edge)
  data = edge_data(graph)[arrange(is_edge_arranged_, edge)]
  return reverse_data_direction(is_edge_arranged_, graph, data)
end

# Support syntax `g[v1 => v2]`
function Base.getindex(graph::AbstractDataGraph, edge::Pair)
  return graph[edgetype(graph)(edge)]
end

function Base.get(graph::AbstractDataGraph, edge::AbstractEdge, default)
  is_edge_arranged_ = is_edge_arranged(graph, edge)
  data = get(edge_data(graph), arrange(is_edge_arranged_, edge), default)
  return reverse_data_direction(is_edge_arranged_, graph, data)
end

function Base.get(graph::AbstractDataGraph, edge::Pair, default)
  return get(graph, edgetype(graph)(edge), default)
end

function Base.get!(graph::AbstractDataGraph, edge::AbstractEdge, default)
  is_edge_arranged_ = is_edge_arranged(graph, edge)
  data = get!(edge_data(graph), arrange(is_edge_arranged_, edge), default)
  return reverse_data_direction(is_edge_arranged_, graph, data)
end

function Base.get!(graph::AbstractDataGraph, edge::Pair, default)
  return get!(graph, edgetype(graph)(edge), default)
end

# Support syntax `g[1, 2] = g[(1, 2)]`
function Base.getindex(graph::AbstractDataGraph, i1, i2, i...)
  return graph[(i1, i2, i...)]
end

function Base.isassigned(graph::AbstractDataGraph, vertex)
  return isassigned(vertex_data(graph), vertex)
end

function Base.isassigned(graph::AbstractDataGraph, vertex::AbstractEdge)
  return isassigned(edge_data(graph), arrange(graph, vertex))
end

function Base.isassigned(graph::AbstractDataGraph, vertex::Pair)
  return isassigned(graph, edgetype(graph)(vertex))
end

function Base.setindex!(graph::AbstractDataGraph, data, vertex)
  set!(vertex_data(graph), vertex, data)
  return graph
end

function Base.setindex!(graph::AbstractDataGraph, data, edge::AbstractEdge)
  is_edge_arranged_ = is_edge_arranged(graph, edge)
  arranged_edge = arrange(is_edge_arranged_, edge)
  arranged_data = reverse_data_direction(is_edge_arranged_, graph, data)
  set!(edge_data(graph), arranged_edge, arranged_data)
  return graph
end

function Base.setindex!(graph::AbstractDataGraph, data, edge::Pair)
  graph[edgetype(graph)(edge)] = data
  return graph
end

# Support syntax `g[1, 2] = g[(1, 2)]`
function Base.setindex!(graph::AbstractDataGraph, x, i1, i2, i...)
  graph[(i1, i2, i...)] = x
  return graph
end

function Graphs.induced_subgraph(graph::AbstractDataGraph, subvertices)
  underlying_subgraph, vlist = Graphs.induced_subgraph(underlying_graph(graph), subvertices)
  subgraph = similar_type(graph)(underlying_subgraph)
  for v in vertices(subgraph)
    if isassigned(graph, v)
      subgraph[v] = graph[v]
    end
  end
  for e in edges(subgraph)
    if isassigned(graph, e)
      subgraph[e] = graph[e]
    end
  end
  return subgraph, vlist
end

#
# Printing
#

function Base.show(io::IO, mime::MIME"text/plain", graph::AbstractDataGraph)
  println(io, "$(typeof(graph)) with $(nv(graph)) vertices:")
  show(io, mime, vertices(graph))
  println(io, "\n")
  println(io, "and $(ne(graph)) edge(s):")
  for e in edges(graph)
    show(io, mime, e)
    println(io)
  end
  println(io)
  println(io, "with vertex data:")
  show(io, mime, vertex_data(graph))
  println(io)
  println(io)
  println(io, "and edge data:")
  show(io, mime, edge_data(graph))
  return nothing
end

Base.show(io::IO, graph::AbstractDataGraph) = show(io, MIME"text/plain"(), graph)

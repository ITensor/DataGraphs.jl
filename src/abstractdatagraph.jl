abstract type AbstractDataGraph{V,VD,ED} <: AbstractGraph{V} end

# Minimal interface
underlying_graph(::AbstractDataGraph) = not_implemented()
underlying_graph_type(::Type{<:AbstractDataGraph}) = not_implemented()
vertex_data(::AbstractDataGraph) = not_implemented()
vertex_data_type(::Type{<:AbstractDataGraph}) = not_implemented()
edge_data(::AbstractDataGraph) = not_implemented()
edge_data_type(::Type{<:AbstractDataGraph}) = not_implemented()

# Derived interface
edgetype(G::Type{<:AbstractDataGraph}) = edgetype(underlying_graph_type(G))
is_directed(G::Type{<:AbstractDataGraph}) = is_directed(underlying_graph_type(G))
underlying_graph_type(graph::AbstractDataGraph) = typeof(underlying_graph(graph))
vertex_data_type(graph::AbstractDataGraph) = vertex_data_type(typeof(graph))
edge_data_type(graph::AbstractDataGraph) = edge_data_type(typeof(graph))

# TODO: delete, defined for AbstractGraph{V}?
vertextype(G::Type{<:AbstractDataGraph}) = vertextype(underlying_graph_type(G))
vertextype(graph::AbstractDataGraph) = vertextype(typeof(graph))

zero(G::Type{<:AbstractDataGraph}) = G()

# Graphs overloads
for f in [
  :a_star,
  :add_edge!,
  :add_vertex!,
  :adjacency_matrix,
  :bellman_ford_shortest_paths,
  :bfs_parents,
  :bfs_tree,
  :boundary_edges,
  :boundary_vertices,
  :boruvka_mst,
  :center,
  :common_neighbors,
  :degree,
  :degree_histogram,
  :desopo_pape_shortest_paths,
  :dfs_parents,
  :dfs_tree,
  :diameter,
  :dijkstra_shortest_paths,
  :eccentricity,
  :eccentricities,
  :edges,
  :edgetype,
  :eltype,
  :enumerate_paths,
  :floyd_warshall_shortest_paths,
  :has_edge,
  :has_path,
  :has_vertex,
  :inneighbors,
  :inner_boundary_vertices,
  :is_connected,
  :is_cyclic,
  :is_directed,
  :is_strongly_connected,
  :is_weakly_connected,
  :mincut,
  :(GraphsFlows.mincut),
  :mincut_partitions,
  :ne,
  :neighbors,
  :neighborhood,
  :neighborhood_dists,
  :outer_boundary_vertices,
  :johnson_shortest_paths,
  :spfa_shortest_paths,
  :yen_k_shortest_paths,
  :kruskal_mst,
  :prim_mst,
  :nv,
  :outneighbors,
  :periphery,
  :radius,
  :symrcm,
  :symrcm_permute,
  :steiner_tree,
  :tree,
  :vertices,
]
  @eval begin
    function $f(graph::AbstractDataGraph, args...; kwargs...)
      return $f(underlying_graph(graph), args...; kwargs...)
    end
  end
end

# Fix for ambiguity error with `AbstractGraph` version
function eccentricity(graph::AbstractDataGraph, distmx::AbstractMatrix)
  return eccentricity(underlying_graph(graph), distmx)
end

@traitfn directed_graph(graph::AbstractDataGraph::IsDirected) = graph

@traitfn function directed_graph(graph::AbstractDataGraph::(!IsDirected))
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

function reverse(graph::AbstractDataGraph)
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

function merge_vertices(
  graph::AbstractDataGraph,
  merge_vertices;
  merge_data=(x, y) -> y,
  merge_vertex_data=merge_data,
  merge_edge_data=merge_data,
  kwargs...,
)
  underlying_merged_graph = merge_vertices(underlying_graph(graph); kwargs...)
  return not_implemented()
end

function merge_vertices!(
  graph::AbstractDataGraph,
  merge_vertices;
  merge_data=(x, y) -> y,
  merge_vertex_data=merge_data,
  merge_edge_data=merge_data,
  kwargs...,
)
  underlying_merged_graph = copy(underlying_graph(graph))
  merge_vertices!(underlying_merged_graph; kwargs...)
  return not_implemented()
end

# Union the vertices and edges of the graphs and
# merge the vertex and edge metadata.
function union(
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
  return DataGraph(underlying_graph_union, vertex_data_merge, edge_data_merge)
end

function union(
  graph1::AbstractDataGraph,
  graph2::AbstractDataGraph,
  graph3::AbstractDataGraph,
  graphs_tail::AbstractDataGraph...;
  kwargs...,
)
  return union(union(graph1, graph2; kwargs...), graph3, graphs_tail...; kwargs...)
end

function rename_vertices(f::Function, graph::AbstractDataGraph)
  renamed_underlying_graph = rename_vertices(f, underlying_graph(graph))
  # TODO: Base the ouput type on `typeof(graph)`, for example:
  # convert_vertextype(eltype(renamed_vertices), typeof(graph))(renamed_underlying_graph)
  renamed_graph = DataGraph{
    vertextype(renamed_underlying_graph),vertex_data_type(graph),edge_data_type(graph)
  }(
    renamed_underlying_graph
  )
  for v in keys(vertex_data(graph))
    renamed_graph[f(v)] = graph[v]
  end
  for e in keys(edge_data(graph))
    renamed_graph[rename_vertices(f, e)] = graph[e]
  end
  return renamed_graph
end

function rem_vertex!(graph::AbstractDataGraph, vertex)
  neighbor_edges = incident_edges(graph, vertex)
  # unset!(vertex_data(graph), to_vertex(graph, vertex...))
  unset!(vertex_data(graph), vertex)
  for neighbor_edge in neighbor_edges
    unset!(edge_data(graph), neighbor_edge)
  end
  rem_vertex!(underlying_graph(graph), vertex)
  return graph
end

function rem_edge!(graph::AbstractDataGraph, edge)
  unset!(edge_data(graph), edge)
  rem_edge!(underlying_graph(graph), edge)
  return graph
end

# Fix ambiguity with:
# Graphs.neighbors(graph::AbstractGraph, v::Integer)
neighbors(graph::AbstractDataGraph, v::Integer) = neighbors(underlying_graph(graph), v)

# Fix ambiguity with:
# Graphs.bfs_tree(graph::AbstractGraph, s::Integer; dir)
function bfs_tree(graph::AbstractDataGraph, s::Integer; kwargs...)
  return bfs_tree(underlying_graph(graph), tuple(s); kwargs...)
end

# Fix ambiguity with:
# Graphs.dfs_tree(graph::AbstractGraph, s::Integer; dir)
function dfs_tree(graph::AbstractDataGraph, s::Integer; kwargs...)
  return dfs_tree(underlying_graph(graph), tuple(s); kwargs...)
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

function getindex(graph::AbstractDataGraph, vertex)
  return vertex_data(graph)[vertex]
end

function get(graph::AbstractDataGraph, vertex, default)
  return get(vertex_data(graph), vertex, default)
end

function getindex(graph::AbstractDataGraph, edge::AbstractEdge)
  is_edge_arranged = is_arranged(graph, edge)
  data = edge_data(graph)[arrange(is_edge_arranged, edge)]
  return reverse_data_direction(is_edge_arranged, graph, data)
end

# Support syntax `g[v1 => v2]`
function getindex(graph::AbstractDataGraph, edge::Pair)
  return graph[edgetype(graph)(edge)]
end

function get(graph::AbstractDataGraph, edge::AbstractEdge, default)
  is_edge_arranged = is_arranged(graph, edge)
  data = get(edge_data(graph), arrange(is_edge_arranged, edge), default)
  return reverse_data_direction(is_edge_arranged, graph, data)
end

function get(graph::AbstractDataGraph, edge::Pair, default)
  return get(graph, edgetype(graph)(edge), default)
end

# Support syntax `g[1, 2] = g[(1, 2)]`
function getindex(graph::AbstractDataGraph, i1, i2, i...)
  return graph[(i1, i2, i...)]
end

function isassigned(graph::AbstractDataGraph, vertex)
  return isassigned(vertex_data(graph), vertex)
end

function isassigned(graph::AbstractDataGraph, vertex::AbstractEdge)
  return isassigned(edge_data(graph), arrange(graph, vertex))
end

function isassigned(graph::AbstractDataGraph, vertex::Pair)
  return isassigned(graph, edgetype(graph)(vertex))
end

function setindex!(graph::AbstractDataGraph, data, vertex)
  set!(vertex_data(graph), vertex, data)
  return graph
end

function setindex!(graph::AbstractDataGraph, data, edge::AbstractEdge)
  is_edge_arranged = is_arranged(graph, edge)
  arranged_edge = arrange(is_edge_arranged, edge)
  arranged_data = reverse_data_direction(is_edge_arranged, graph, data)
  set!(edge_data(graph), arranged_edge, arranged_data)
  return graph
end

function setindex!(graph::AbstractDataGraph, data, edge::Pair)
  graph[edgetype(graph)(edge)] = data
  return graph
end

# Support syntax `g[1, 2] = g[(1, 2)]`
function setindex!(graph::AbstractDataGraph, x, i1, i2, i...)
  graph[(i1, i2, i...)] = x
  return graph
end

function induced_subgraph(graph::AbstractDataGraph, subvertices::Vector)
  underlying_subgraph, vlist = induced_subgraph(underlying_graph(graph), subvertices)
  subgraph = typeof(graph)(underlying_subgraph)
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

function show(io::IO, mime::MIME"text/plain", graph::AbstractDataGraph)
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

show(io::IO, graph::AbstractDataGraph) = show(io, MIME"text/plain"(), graph)

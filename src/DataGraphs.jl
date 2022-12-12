module DataGraphs
using Dictionaries
using Graphs
using NamedGraphs
using SimpleTraits

using NamedGraphs: copy_keys_values, all_edges

#
# imports
#

import Base:
  get,
  getindex,
  setindex!,
  convert,
  show,
  isassigned,
  eltype,
  copy,
  hvncat,
  hcat,
  vcat,
  union,
  zero
import Graphs:
  adjacency_matrix,
  add_edge!,
  add_vertex!,
  bfs_parents,
  bfs_tree,
  common_neighbors,
  connected_components,
  connected_components!,
  degree,
  degree_histogram,
  dfs_parents,
  dfs_tree,
  edges,
  edgetype,
  has_edge,
  has_path,
  has_vertex,
  induced_subgraph,
  inneighbors,
  is_connected,
  is_cyclic,
  is_directed,
  is_strongly_connected,
  is_weakly_connected,
  merge_vertices,
  merge_vertices!,
  ne,
  neighbors,
  neighborhood,
  neighborhood_dists,
  a_star,
  bellman_ford_shortest_paths,
  enumerate_paths,
  desopo_pape_shortest_paths,
  dijkstra_shortest_paths,
  floyd_warshall_shortest_paths,
  johnson_shortest_paths,
  spfa_shortest_paths,
  yen_k_shortest_paths,
  boruvka_mst,
  kruskal_mst,
  prim_mst,
  nv,
  outneighbors,
  rem_edge!,
  rem_vertex!,
  reverse,
  vertices

# TODO: Can we remove the dependency on `NamedGraphs`?
# Maybe need a `GraphExtensions.jl` or
# `GraphInterfaces.jl` package.
import NamedGraphs:
  ⊔,
  convert_vertextype,
  directed_graph,
  disjoint_union,
  incident_edges,
  rename_vertices,
  vertextype

# General functions
not_implemented() = error("Not implemented")

include("abstractdatagraph.jl")
include("arrange.jl")
include("datagraph.jl")

#
# exports
#

export DataGraph,
  vertex_type,
  directed_graph,
  AbstractDataGraph,
  map_vertex_data,
  map_edge_data,
  map_data,
  disjoint_union,
  ⊔

end # module DataGraphs

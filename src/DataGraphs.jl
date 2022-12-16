module DataGraphs
using Dictionaries
using Graphs
using GraphsFlows
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
  a_star,
  adjacency_matrix,
  add_edge!,
  add_vertex!,
  bellman_ford_shortest_paths,
  bfs_parents,
  bfs_tree,
  boruvka_mst,
  center,
  common_neighbors,
  connected_components,
  connected_components!,
  degree,
  degree_histogram,
  desopo_pape_shortest_paths,
  dfs_parents,
  dfs_tree,
  diameter,
  dijkstra_shortest_paths,
  eccentricity,
  edges,
  edgetype,
  enumerate_paths,
  floyd_warshall_shortest_paths,
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
  johnson_shortest_paths,
  merge_vertices,
  merge_vertices!,
  mincut,
  ne,
  neighbors,
  neighborhood,
  neighborhood_dists,
  periphery,
  radius,
  spfa_shortest_paths,
  yen_k_shortest_paths,
  kruskal_mst,
  prim_mst,
  nv,
  outneighbors,
  periphery,
  rem_edge!,
  rem_vertex!,
  reverse,
  tree,
  vertices

# TODO: Can we remove the dependency on `NamedGraphs`?
# Maybe need a `GraphExtensions.jl` or
# `GraphInterfaces.jl` package.
import NamedGraphs:
  ⊔,
  convert_vertextype,
  directed_graph,
  disjoint_union,
  eccentricities,
  incident_edges,
  mincut_partitions,
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
  AbstractDataGraph,
  directed_graph,
  disjoint_union,
  map_vertex_data,
  map_edge_data,
  map_data,
  ⊔

end # module DataGraphs

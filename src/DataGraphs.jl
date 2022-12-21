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
  kruskal_mst,
  merge_vertices,
  merge_vertices!,
  mincut,
  ne,
  neighbors,
  neighborhood,
  neighborhood_dists,
  nv,
  outneighbors,
  periphery,
  prim_mst,
  radius,
  rem_edge!,
  rem_vertex!,
  reverse,
  spfa_shortest_paths,
  steiner_tree,
  topological_sort_by_dfs,
  tree,
  vertices,
  yen_k_shortest_paths

# TODO: Can we remove the dependency on `NamedGraphs`?
# Maybe need a `GraphExtensions.jl` or
# `GraphInterfaces.jl` package.
import NamedGraphs:
  ⊔,
  boundary_edges,
  boundary_vertices,
  convert_vertextype,
  directed_graph,
  disjoint_union,
  eccentricities,
  incident_edges,
  inner_boundary_vertices,
  outer_boundary_vertices,
  mincut_partitions,
  rename_vertices,
  symrcm,
  symrcm_permute,
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

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
  union
import Graphs:
  adjacency_matrix,
  add_edge!,
  add_vertex!,
  bfs_parents,
  bfs_tree,
  dfs_parents,
  dfs_tree,
  edges,
  edgetype,
  has_edge,
  has_vertex,
  induced_subgraph,
  is_connected,
  is_cyclic,
  is_directed,
  is_strongly_connected,
  is_weakly_connected,
  ne,
  neighbors,
  nv,
  rem_edge!,
  rem_vertex!,
  vertices

# TODO: Can we remove the dependency on `NamedGraphs`?
# Maybe need a `GraphExtensions.jl` or
# `GraphInterfaces.jl` package.
import NamedGraphs:
  rename_vertices, disjoint_union, ⊔, directed_graph, vertextype, convert_vertextype

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

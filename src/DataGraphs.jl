module DataGraphs
using Dictionaries
using Graphs
using MultiDimDictionaries
using NamedGraphs
using SimpleTraits

using MultiDimDictionaries: tuple_convert, SliceIndex, ElementIndex

#
# imports
#

import Base:
  get, getindex, setindex!, convert, show, isassigned, eltype, copy, hvncat, hcat, vcat
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
import MultiDimDictionaries: IndexType
import NamedGraphs: disjoint_union, ⊔, to_vertex

# Dictionaries.jl patch
# TODO: delete once fixed in Dictionaries.jl
convert(::Type{Dictionary{I,T}}, dict::Dictionary{I,T}) where {I,T} = dict

# General functions
not_implemented() = error("Not implemented")

# Returns just the edges of a directed graph,
# but both edge directions of an undirected graph.
@traitfn function all_edges(g::::IsDirected)
  return edges(g)
end

@traitfn function all_edges(g::::(!IsDirected))
  e = edges(g)
  return Iterators.flatten(zip(e, reverse.(e)))
end

include("abstractdatagraph.jl")
include("datagraph.jl")
include("nameddimdatagraph.jl")

#
# exports
#

export DataGraph,
  NamedDimDataGraph,
  AbstractNamedDimDataGraph,
  AbstractDataGraph,
  map_vertex_data,
  map_edge_data,
  map_data,
  disjoint_union,
  ⊔

end # module DataGraphs

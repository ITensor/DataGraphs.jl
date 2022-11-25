module DataGraphs
using Dictionaries
using Graphs
# using MultiDimDictionaries # TODO: Remove once IndexType is removed
using NamedGraphs
using SimpleTraits

# TODO: Remove
# using MultiDimDictionaries: tuple_convert, SliceIndex, ElementIndex

###############################################################################
# Patches and extensions for dependent packages
#

# Workaround for: https://github.com/andyferris/Dictionaries.jl/issues/98
# TODO: Move to Dictionaries.jl file in NamedGraphs.jl
copy_keys_values(d::Dictionary) = Dictionary(copy(d.indices), copy(d.values))

# Dictionaries.jl patch
# TODO: delete once fixed in Dictionaries.jl
# TODO: Move to Dictionaries.jl file in NamedGraphs.jl
Base.convert(::Type{Dictionary{I,T}}, dict::Dictionary{I,T}) where {I,T} = dict

# Returns just the edges of a directed graph,
# but both edge directions of an undirected graph.
# TODO: Move to NamedGraphs.jl
@traitfn function all_edges(g::::IsDirected)
  return edges(g)
end

@traitfn function all_edges(g::::(!IsDirected))
  e = edges(g)
  return Iterators.flatten(zip(e, reverse.(e)))
end

#
# Patches and extensions for dependent packages
###############################################################################

#
# imports
#

import Base:
  get, getindex, setindex!, convert, show, isassigned, eltype, copy, hvncat, hcat, vcat, union
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
# import MultiDimDictionaries: IndexType # TODO: Remove

# TODO: Can we remove this?
# Maybe need a `GraphsExtensions.jl` package
import NamedGraphs:
  rename_vertices,
  disjoint_union,
  ⊔,
#  to_vertex, # TODO: Deprecate
  directed_graph,
  vertextype
  #=vertex_type,=#

# General functions
not_implemented() = error("Not implemented")

include("abstractdatagraph.jl")
include("datagraph.jl")
# include("nameddimdatagraph.jl")

#
# exports
#

export DataGraph,
  vertex_type,
  directed_graph,
#  VertexDataGraph,
#  AbstractVertexDataGraph,
#  NamedDimDataGraph,
#  AbstractNamedDimDataGraph,
  AbstractDataGraph,
  map_vertex_data,
  map_edge_data,
  map_data,
  disjoint_union,
  ⊔

end # module DataGraphs

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

import Base: get, getindex, setindex!, convert, show, isassigned, eltype, copy, hvncat, hcat, vcat
import Graphs:
  add_edge!,
  add_vertex!,
  edgetype,
  ne,
  nv,
  vertices,
  edges,
  has_edge,
  has_vertex,
  neighbors,
  induced_subgraph,
  is_directed,
  adjacency_matrix
import MultiDimDictionaries: IndexType
import NamedGraphs: disjoint_union, ⊔

# Dictionaries.jl patch
# TODO: delete once fixed in Dictionaries.jl
convert(::Type{Dictionary{I,T}}, dict::Dictionary{I,T}) where {I,T} = dict

# General functions
_not_implemented() = error("Not implemented")

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
  NamedDimDataGraph, AbstractNamedDimDataGraph, AbstractDataGraph, map_vertex_data, map_edge_data, map_data,
  disjoint_union, ⊔

end # module DataGraphs

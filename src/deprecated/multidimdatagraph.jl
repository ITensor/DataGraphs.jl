# TODO: define VertexMultiDimDataGraph, a graph with only data on the
# vertices, and EdgeMultiDimDataGraph, a graph with only data on the edges.
struct MultiDimDataGraph{VD,ED,V,E,G<:AbstractGraph} <: AbstractDataGraph{VD,ED,V,E}
  underlying_graph::G
  vertex_data::MultiDimDictionary{V,VD}
  edge_data::Dictionary{E,ED}
end
underlying_graph(graph::MultiDimDataGraph) = graph.underlying_graph
vertex_data(graph::MultiDimDataGraph) = graph.vertex_data
edge_data(graph::MultiDimDataGraph) = graph.edge_data

copy(graph::MultiDimDataGraph) = MultiDimDataGraph(copy(underlying_graph(graph)), copy(vertex_data(graph)), copy(edge_data(graph)))

function MultiDimDataGraph{VD,ED}(
  underlying_graph::AbstractGraph,
  vertex_data::MultiDimDictionary{V,VD},
  edge_data::Dictionary{E,ED},
) where {VD,ED,V,E}
  G = typeof(underlying_graph)
  return MultiDimDataGraph{VD,ED,V,E,G}(underlying_graph, vertex_data, edge_data)
end

function MultiDimDataGraph{VD,ED}(
  underlying_graph::AbstractGraph,
) where {VD,ED}
  V = eltype(underlying_graph)
  E = edgetype(underlying_graph)
  vertex_data = MultiDimDictionary{V,VD}()
  edge_data = Dictionary{E,ED}()
  return MultiDimDataGraph{VD,ED}(underlying_graph, vertex_data, edge_data)
end

MultiDimDataGraph(underlying_graph::AbstractGraph) = MultiDimDataGraph{Any,Any}(underlying_graph)
MultiDimDataGraph{VD}(underlying_graph::AbstractGraph) where {VD} = MultiDimDataGraph{VD,Any}(underlying_graph)

## function default_data(
##   index_type::Type,
##   data_type::Type,
##   indices_function::Function,
##   underlying_graph::AbstractGraph,
##   ::Nothing
## )
##   return similar(Indices(indices_function(underlying_graph)), data_type)
## end
## 
## # XXX: Assumes `is_directed(underlying_graph)`.
## function default_data(
##   index_type::Type{<:AbstractEdge},
##   data_type::Type,
##   indices_function::Function,
##   underlying_graph::AbstractGraph,
##   ::Nothing
## )
##   out_indices = indices_function(underlying_graph)
##   in_indices = reverse.(out_indices)
##   # Interleave the indices.
##   indices = collect(Iterators.flatten(zip(out_indices, in_indices)))
##   return similar(Indices(indices), data_type)
## end

## function MultiDimDataGraph{VD,ED}(
##   underlying_graph::G,
##   vertex_data,
##   edge_data
## ) where {VD,ED,G<:AbstractGraph}
##   V = eltype(underlying_graph)
##   E = edgetype(underlying_graph)
##   vertex_data = MultiDimDictionary{V,VD}(vertices(underlying_graph), vertex_data)
##   edge_data = MultiDimDictionary{E,ED}(edges(underlying_graph), edge_data)
## 
##   @show vertex_data
##   @show edge_data
## 
##   return MultiDimDataGraph{VD,ED,V,E,G}(underlying_graph, vertex_data, edge_data)
## end
## 
## copy(graph::MultiDimDataGraph) = MultiDimDataGraph(copy(underlying_graph(graph)), copy(vertex_data(graph)), copy(edge_data(graph)))
## 
## function MultiDimDataGraph{VD}(
##   underlying_graph::AbstractGraph,
##   vertex_data,
##   edge_data
## ) where {VD}
##   ED = data_type(edge_data)
##   return MultiDimDataGraph{VD,ED}(underlying_graph, vertex_data, edge_data)
## end
## 
## function (MultiDimDataGraph{VD,ED} where {VD})(
##   underlying_graph::AbstractGraph,
##   vertex_data,
##   edge_data
## ) where {ED}
##   VD = data_type(vertex_data)
##   return MultiDimDataGraph{VD,ED}(underlying_graph, vertex_data, edge_data)
## end
## 
## function MultiDimDataGraph(
##   underlying_graph::AbstractGraph,
##   vertex_data,
##   edge_data
## )
##   VD = data_type(vertex_data)
##   ED = data_type(edge_data)
##   return MultiDimDataGraph{VD,ED}(underlying_graph, vertex_data, edge_data)
## end
## 
## #
# kwarg versions call arg versions
#

## function MultiDimDataGraph{VD,ED}(
##   underlying_graph::AbstractGraph;
##   vertex_data=nothing,
##   edge_data=nothing
## ) where {VD,ED}
##   return MultiDimDataGraph{VD,ED}(underlying_graph, vertex_data, edge_data)
## end
## 
## function MultiDimDataGraph{VD}(
##   underlying_graph::AbstractGraph;
##   vertex_data=nothing,
##   edge_data=nothing
## ) where {VD}
##   return MultiDimDataGraph{VD}(underlying_graph, vertex_data, edge_data)
## end
## 
## function (MultiDimDataGraph{VD,ED} where {VD})(
##   underlying_graph::AbstractGraph;
##   vertex_data=nothing,
##   edge_data=nothing
## ) where {ED}
##   return (MultiDimDataGraph{VD,ED} where {VD})(underlying_graph, vertex_data, edge_data)
## end
## 
## function MultiDimDataGraph(
##   underlying_graph::AbstractGraph;
##   vertex_data=nothing,
##   edge_data=nothing
## )
##   return MultiDimDataGraph(underlying_graph, vertex_data, edge_data)
## end

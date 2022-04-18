# TODO: define VertexDataGraph, a graph with only data on the
# vertices, and EdgeDataGraph, a graph with only data on the edges.
struct DataGraph{VD,ED,V,E,G<:AbstractGraph} <: AbstractDataGraph{VD,ED,V,E}
  underlying_graph::G
  vertex_data::Dictionary{V,VD}
  edge_data::Dictionary{E,ED}
end
underlying_graph(graph::DataGraph) = graph.underlying_graph
vertex_data(graph::DataGraph) = graph.vertex_data
edge_data(graph::DataGraph) = graph.edge_data

function copy(graph::DataGraph)
  return DataGraph(
    copy(underlying_graph(graph)), copy(vertex_data(graph)), copy(edge_data(graph))
  )
end

function DataGraph{VD,ED}(
  underlying_graph::AbstractGraph,
  vertex_data::Dictionary{V,VD},
  edge_data::Dictionary{E,ED},
) where {VD,ED,V,E}
  G = typeof(underlying_graph)
  return DataGraph{VD,ED,V,E,G}(underlying_graph, vertex_data, edge_data)
end

function DataGraph{VD,ED}(underlying_graph::AbstractGraph) where {VD,ED}
  V = eltype(underlying_graph)
  E = edgetype(underlying_graph)
  vertex_data = Dictionary{V,VD}()
  edge_data = Dictionary{E,ED}()
  return DataGraph{VD,ED}(underlying_graph, vertex_data, edge_data)
end

DataGraph(underlying_graph::AbstractGraph) = DataGraph{Any,Any}(underlying_graph)
function DataGraph{VD}(underlying_graph::AbstractGraph) where {VD}
  return DataGraph{VD,Any}(underlying_graph)
end

## function DataGraph{VD,ED}(
##   underlying_graph::AbstractGraph,
##   vertex_data::Dictionary{V,VD},
##   edge_data::Dictionary{E,ED},
## ) where {VD,ED,V,E}
##   G = typeof(underlying_graph)
##   return DataGraph{VD,ED,V,E,G}(underlying_graph, vertex_data, edge_data)
## end
## 
## function DataGraph{VD,ED}(
##   underlying_graph::AbstractGraph,
##   vertex_data::UndefInitializer,
##   edge_data::UndefInitializer,
## ) where {VD,ED}
##   V = eltype(underlying_graph)
##   E = edgetype(underlying_graph)
##   vertex_data = Dictionary{V,VD}()
##   edge_data = Dictionary{E,ED}()
##   return DataGraph{VD,ED}(underlying_graph, vertex_data, edge_data)
## end

## function DataGraph{VD,ED}(
##   underlying_graph::AbstractGraph,
##   vertex_data::UndefInitializer,
##   edge_data::UndefInitializer,
## ) where {VD,ED}
##   V = eltype(underlying_graph)
##   E = edgetype(underlying_graph)
##   vertex_data = Dictionary{V,VD}(vertices(underlying_graph), undef)
##   edge_data = Dictionary{E,ED}(all_edges(underlying_graph), undef)
##   return DataGraph{VD,ED}(underlying_graph, vertex_data, edge_data)
## end

## function DataGraph{VD,ED}(
##   underlying_graph::AbstractGraph,
##   vertex_data::UndefInitializer,
##   edge_data::UndefInitializer,
## ) where {VD,ED}
##   V = eltype(underlying_graph)
##   E = edgetype(underlying_graph)
##   vertex_data = Dictionary{V,VD}(vertices(underlying_graph), undef)
##   edge_data = Dictionary{E,ED}(all_edges(underlying_graph), undef)
##   return DataGraph{VD,ED}(underlying_graph, vertex_data, edge_data)
## end

## function DataGraph{VD,ED}(
##   underlying_graph::G,
##   vertex_data,
##   edge_data
## ) where {VD,ED,G<:AbstractGraph}
##   V = eltype(underlying_graph)
##   E = edgetype(underlying_graph)
##   vertex_data = default_data(V, VD, vertices, underlying_graph, vertex_data)
##   edge_data = default_data(E, ED, edges, underlying_graph, edge_data)
##   return DataGraph{VD,ED,V,E,G}(underlying_graph, vertex_data, edge_data)
## end
## 
## function DataGraph{VD}(
##   underlying_graph::AbstractGraph,
##   vertex_data,
##   edge_data
## ) where {VD}
##   ED = data_type(edge_data)
##   return DataGraph{VD,ED}(underlying_graph, vertex_data, edge_data)
## end
## 
## function (DataGraph{VD,ED} where {VD})(
##   underlying_graph::AbstractGraph,
##   vertex_data,
##   edge_data
## ) where {ED}
##   VD = data_type(vertex_data)
##   return DataGraph{VD,ED}(underlying_graph, vertex_data, edge_data)
## end
## 
## function DataGraph(
##   underlying_graph::AbstractGraph,
##   vertex_data,
##   edge_data
## )
##   VD = data_type(vertex_data)
##   ED = data_type(edge_data)
##   return DataGraph{VD,ED}(underlying_graph, vertex_data, edge_data)
## end
## 
## #
## # kwarg versions call arg versions
## #
## 
## function DataGraph{VD,ED}(
##   underlying_graph::AbstractGraph;
##   vertex_data=nothing,
##   edge_data=nothing
## ) where {VD,ED}
##   return DataGraph{VD,ED}(underlying_graph, vertex_data, edge_data)
## end
## 
## function DataGraph{VD}(
##   underlying_graph::AbstractGraph;
##   vertex_data=nothing,
##   edge_data=nothing
## ) where {VD}
##   return DataGraph{VD}(underlying_graph, vertex_data, edge_data)
## end
## 
## function (DataGraph{VD,ED} where {VD})(
##   underlying_graph::AbstractGraph;
##   vertex_data=nothing,
##   edge_data=nothing
## ) where {ED}
##   return (DataGraph{VD,ED} where {VD})(underlying_graph, vertex_data, edge_data)
## end
## 
## function DataGraph(
##   underlying_graph::AbstractGraph;
##   vertex_data=nothing,
##   edge_data=nothing
## )
##   return DataGraph(underlying_graph, vertex_data, edge_data)
## end

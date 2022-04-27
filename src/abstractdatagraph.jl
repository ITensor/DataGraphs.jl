abstract type AbstractDataGraph{VD,ED,V,E} <: AbstractGraph{V} end

# Field access
underlying_graph(graph::AbstractDataGraph) = not_implemented()
vertex_data(graph::AbstractDataGraph) = not_implemented()
edge_data(graph::AbstractDataGraph) = not_implemented()

is_directed(G::Type{<:AbstractDataGraph}) = not_implemented()

# Graphs overloads
for f in [
  :add_edge!,
  :add_vertex!,
  :adjacency_matrix,
  :bfs_parents,
  :bfs_tree,
  :dfs_parents,
  :dfs_tree,
  :edges,
  :edgetype,
  :eltype,
  :has_edge,
  :has_vertex,
  :is_connected,
  :is_cyclic,
  :is_directed,
  :is_strongly_connected,
  :is_weakly_connected,
  :ne,
  :neighbors,
  :nv,
  :vertices,
]
  @eval begin
    $f(graph::AbstractDataGraph, args...; kwargs...) = $f(underlying_graph(graph), args...; kwargs...)
  end
end

function rem_vertex!(graph::AbstractDataGraph, vertex...)
  neighbor_edges = incident_edges(graph, vertex...)
  rem_vertex!(underlying_graph(graph), vertex...)
  unset!(vertex_data(graph), to_vertex(graph, vertex...))
  for neighbor_edge in neighbor_edges
    unset!(edge_data(graph), neighbor_edge)
  end
  return graph
end

# Fix ambiguity with:
# Graphs.neighbors(graph::AbstractGraph, v::Integer)
neighbors(graph::AbstractDataGraph, v::Integer) = neighbors(underlying_graph(graph), v)

# Fix ambiguity with:
# Graphs.bfs_tree(graph::AbstractGraph, s::Integer; dir)
bfs_tree(graph::AbstractDataGraph, s::Integer; kwargs...) = bfs_tree(underlying_graph(graph), tuple(s); kwargs...)

# Fix ambiguity with:
# Graphs.dfs_tree(graph::AbstractGraph, s::Integer; dir)
dfs_tree(graph::AbstractDataGraph, s::Integer; kwargs...) = dfs_tree(underlying_graph(graph), tuple(s); kwargs...)

# Vertex or Edge trait
struct VertexIndex <: IndexType end
struct EdgeIndex <: IndexType end

# TODO: To allow the syntax `g[1, 1]` as a shorthand for the index `g[(1, 1)]`,
# define `IndexType(graph::AbstractGraph, args...) = IndexType(graph::AbstractGraph, args)`.
function IndexType(graph::AbstractGraph, index)
  return error("$index doesn't represent a vertex or an edge for graph:\n$graph.")
end
IndexType(graph::AbstractGraph{V}, ::V) where {V} = VertexIndex()
IndexType(graph::AbstractGraph, ::AbstractEdge) = EdgeIndex()
IndexType(graph::AbstractGraph, ::Pair) = EdgeIndex()

# Handles multi-dimensional indexing.
# XXX: Maybe only define for `NamedDimDataGraph`?
IndexType(graph::AbstractGraph, ::Any...) = VertexIndex()

data(::VertexIndex, graph::AbstractDataGraph) = vertex_data(graph)
data(::EdgeIndex, graph::AbstractDataGraph) = edge_data(graph)

# Slicing is assumed to slice vertices (vertex-induced subgraph)
data(::SliceIndex, graph::AbstractDataGraph) = vertex_data(graph)

index_type(::VertexIndex, graph::AbstractDataGraph, v) = eltype(graph)(v)
index_type(::EdgeIndex, graph::AbstractDataGraph, e) = edgetype(graph)(e)

# Handles multi-dimensional indexing.
# XXX: Maybe only define for `NamedDimDataGraph`?
function index_type(::VertexIndex, graph::AbstractDataGraph, v1, v2, vs...)
  return eltype(graph)(tuple(v1, v2, vs...))
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
    graph′[e] = f(graph[e])
  end
  return graph′
end

function map_data(f, graph::AbstractDataGraph; vertices=nothing, edges=nothing)
  graph = map_vertex_data(f, graph; vertices)
  return map_edge_data(f, graph; edges)
end

# Data access
function getindex(graph::AbstractDataGraph, index...)
  return getindex(IndexType(graph, index...), graph, index...)
end
function getindex(ve::IndexType, graph::AbstractDataGraph, index...)
  return getindex(data(ve, graph), index_type(ve, graph, index...))
end

function isassigned(graph::AbstractDataGraph, index)
  return isassigned(IndexType(graph, index), graph, index)
end
function isassigned(ve::IndexType, graph::AbstractDataGraph, index)
  return isassigned(data(ve, graph), index_type(ve, graph, index))
end

function setindex!(graph::AbstractDataGraph, x, index...)
  return setindex!(IndexType(graph, index...), graph, x, index...)
end
function setindex!(ve::VertexIndex, graph::AbstractDataGraph, x, index...)
  @assert has_vertex(graph, index...)
  set!(data(ve, graph), index_type(ve, graph, index...), x)
  return graph
end

# Induced subgraph
## function getindex(g::AbstractDataGraph, sub_vertices::Vector)
##   return induced_subgraph(g, sub_vertices)[1]
## end

## function _induced_subgraph(graph::AbstractDataGraph, vlist_or_elist)
##   parent_induced_subgraph = induced_subgraph(underlying_graph(graph), vlist_or_elist)
##   # TODO: Get the data of the subgraph.
##   return not_implemented()
## end

## function induced_subgraph(graph::AbstractDataGraph, vlist_or_elist)
##   return _induced_subgraph(graph, vlist_or_elist)
## end

# fix ambiguity error:
# ERROR: MethodError: induced_subgraph(::ITensorNetwork{Int64}, ::Vector{Int64}) is ambiguous. Candidates:
# induced_subgraph(g::T, vlist::AbstractVector{U}) where {U<:Integer, T<:Graphs.AbstractGraph} in Graphs at /home/mfishman/.julia/packages/Graphs/Mih78/src/operators.jl:639
# induced_subgraph(graph::ITensorNetworks.DataGraphs.AbstractDataGraph, vlist_or_elist) in ITensorNetworks.DataGraphs at /home/mfishman/.julia/dev/ITensorNetworks/src/DataGraphs/src/DataGraphs.jl:96
## function induced_subgraph(
##   graph::AbstractDataGraph, vlist_or_elist::AbstractVector{<:Integer}
## )
##   return _induced_subgraph(graph, vlist_or_elist)
## end

# Overload this to have custom behavior for the data in different directions,
# such as complex conjugation.
reverse_direction(x) = x
function setindex!(ve::EdgeIndex, graph::AbstractDataGraph, x, args...)
  i = index_type(ve, graph, args...)
  @assert has_edge(graph, i)
  # Handles edges in both directions. Assumes data is the same, potentially
  # up to `reverse_direction(x)`.
  set!(data(ve, graph), i, x)
  set!(data(ve, graph), reverse(i), reverse_direction(x))
  return graph
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

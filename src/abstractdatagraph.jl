abstract type AbstractDataGraph{VD,ED,V,E} <: AbstractGraph{V} end

# Field access
underlying_graph(graph::AbstractDataGraph) = _not_implemented()
vertex_data(graph::AbstractDataGraph) = _not_implemented()
edge_data(graph::AbstractDataGraph) = _not_implemented()

# Graphs overloads
for f in [:edgetype, :nv, :ne, :vertices, :edges, :eltype, :has_edge, :has_vertex, :neighbors, :is_directed, :adjacency_matrix]
  @eval begin
    $f(graph::AbstractDataGraph, args...) = $f(underlying_graph(graph), args...)
  end
end

# Fix ambiguity with:
# neighbors(g::Graphs.AbstractGraph, v::Integer)
# in Graphs
neighbors(graph::AbstractDataGraph, v::Integer) = neighbors(underlying_graph(graph), v)

# Vertex or Edge trait
abstract type VertexOrEdge end
struct IsVertex <: VertexOrEdge end
struct IsEdge <: VertexOrEdge end

# TODO: To allow the syntax `g[1, 1]` as a shorthand for the index `g[(1, 1)]`,
# define `is_vertex_or_edge(graph::AbstractGraph, args...) = is_vertex_or_edge(graph::AbstractGraph, args)`.
is_vertex_or_edge(graph::AbstractGraph, v_or_e) = error("$v_or_e doesn't represent a vertex or an edge for graph:\n$graph.")
is_vertex_or_edge(graph::AbstractGraph{V}, ::V) where {V} = IsVertex()
is_vertex_or_edge(graph::AbstractGraph, ::AbstractEdge) = IsEdge()
is_vertex_or_edge(graph::AbstractGraph, ::Pair) = IsEdge()

# Handles multi-dimensional indexing.
# XXX: Maybe only define for `MultiDimDataGraph`?
is_vertex_or_edge(graph::AbstractGraph, ::Any...) = IsVertex()

data(::IsVertex, graph::AbstractDataGraph) = vertex_data(graph)
data(::IsEdge, graph::AbstractDataGraph) = edge_data(graph)
index_type(::IsVertex, graph::AbstractDataGraph, v) = eltype(graph)(v)
index_type(::IsEdge, graph::AbstractDataGraph, e) = edgetype(graph)(e)

# Handles multi-dimensional indexing.
# XXX: Maybe only define for `MultiDimDataGraph`?
index_type(::IsVertex, graph::AbstractDataGraph, v1, v2, vs...) = eltype(graph)(tuple(v1, v2, vs...))

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

function map_data(f, graph::AbstractDataGraph; vertices, edges)
  graph = map_vertex_data(f, graph; vertices)
  return map_edge_data(f, graph; edges)
end

# Data access
getindex(graph::AbstractDataGraph, v_or_e...) = getindex(is_vertex_or_edge(graph, v_or_e...), graph, v_or_e...)
getindex(ve::VertexOrEdge, graph::AbstractDataGraph, v_or_e...) = getindex(data(ve, graph), index_type(ve, graph, v_or_e...))

isassigned(graph::AbstractDataGraph, v_or_e) = isassigned(is_vertex_or_edge(graph, v_or_e), graph, v_or_e)
isassigned(ve::VertexOrEdge, graph::AbstractDataGraph, v_or_e) = isassigned(data(ve, graph), index_type(ve, graph, v_or_e))

setindex!(graph::AbstractDataGraph, x, v_or_e...) = setindex!(is_vertex_or_edge(graph, v_or_e...), graph, x, v_or_e...)
function setindex!(ve::IsVertex, graph::AbstractDataGraph, x, v_or_e...)
  @assert has_vertex(graph, v_or_e...)
  set!(data(ve, graph), index_type(ve, graph, v_or_e...), x)
  return graph
end

# Induced subgraph
function getindex(g::AbstractDataGraph, sub_vertices::Vector)
  return induced_subgraph(g, sub_vertices)[1]
end

function _induced_subgraph(graph::AbstractDataGraph, vlist_or_elist)
  parent_induced_subgraph = induced_subgraph(underlying_graph(graph), vlist_or_elist)
  # TODO: Get the data of the subgraph.
  return _not_implemented()
end

function induced_subgraph(graph::AbstractDataGraph, vlist_or_elist)
  return _induced_subgraph(graph, vlist_or_elist)
end

# fix ambiguity error:
# ERROR: MethodError: induced_subgraph(::ITensorNetwork{Int64}, ::Vector{Int64}) is ambiguous. Candidates:
# induced_subgraph(g::T, vlist::AbstractVector{U}) where {U<:Integer, T<:Graphs.AbstractGraph} in Graphs at /home/mfishman/.julia/packages/Graphs/Mih78/src/operators.jl:639
# induced_subgraph(graph::ITensorNetworks.DataGraphs.AbstractDataGraph, vlist_or_elist) in ITensorNetworks.DataGraphs at /home/mfishman/.julia/dev/ITensorNetworks/src/DataGraphs/src/DataGraphs.jl:96
function induced_subgraph(graph::AbstractDataGraph, vlist_or_elist::AbstractVector{<:Integer})
  return _induced_subgraph(graph, vlist_or_elist)
end

# Overload this to have custom behavior for the data in different directions,
# such as complex conjugation.
reverse_direction(x) = x
function setindex!(ve::IsEdge, graph::AbstractDataGraph, x, args...)
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

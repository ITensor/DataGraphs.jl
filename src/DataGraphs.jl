module DataGraphs
  using Dictionaries
  using Graphs

  #
  # imports
  #

  import Base: get, getindex, setindex!, convert, show, isassigned, eltype, copy
  import Graphs: edgetype, ne, nv, vertices, edges, has_edge, has_vertex, neighbors, induced_subgraph, is_directed, adjacency_matrix

  #
  # exports
  #

  export DataGraph, AbstractDataGraph, map_vertex_data, map_edge_data, map_data

  # Dictionaries.jl patch
  # TODO: delete once fixed in Dictionaries.jl
  convert(::Type{Dictionary{I,T}}, dict::Dictionary{I,T}) where {I, T} = dict

  # General functions
  _not_implemented() = error("Not implemented")

  #
  # AbstractDataGraph
  #

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
  is_vertex_or_edge(graph::AbstractGraph{V}, ::Pair{V,V}) where {V} = IsEdge()

  data(::IsVertex, graph::AbstractDataGraph) = vertex_data(graph)
  data(::IsEdge, graph::AbstractDataGraph) = edge_data(graph)
  index_type(::IsVertex, graph::AbstractDataGraph, v_or_e) = eltype(graph)(v_or_e)
  index_type(::IsEdge, graph::AbstractDataGraph, v_or_e) = edgetype(graph)(v_or_e)

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
  getindex(graph::AbstractDataGraph, v_or_e) = getindex(is_vertex_or_edge(graph, v_or_e), graph, v_or_e)
  getindex(ve::VertexOrEdge, graph::AbstractDataGraph, v_or_e) = getindex(data(ve, graph), index_type(ve, graph, v_or_e))

  isassigned(graph::AbstractDataGraph, v_or_e) = isassigned(is_vertex_or_edge(graph, v_or_e), graph, v_or_e)
  isassigned(ve::VertexOrEdge, graph::AbstractDataGraph, v_or_e) = isassigned(data(ve, graph), index_type(ve, graph, v_or_e))

  setindex!(graph::AbstractDataGraph, x, v_or_e) = setindex!(is_vertex_or_edge(graph, v_or_e), graph, x, v_or_e)
  function setindex!(ve::IsVertex, graph::AbstractDataGraph, x, v_or_e)
    setindex!(data(ve, graph), x, index_type(ve, graph, v_or_e))
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
    # Handles edges in both directions. Assumes data is the same, potentially
    # up to `reverse_direction(x)`.
    setindex!(data(ve, graph), x, i)
    setindex!(data(ve, graph), reverse_direction(x), reverse(i))
    return graph
  end

  #
  # Helper functions for constructing AbstractDataGraph
  #

  function default_data(
    index_type::Type,
    data_type::Type,
    indices_function::Function,
    underlying_graph::AbstractGraph,
    ::Nothing
  )
    return similar(Indices(indices_function(underlying_graph)), data_type)
  end

  # XXX: Assumes `is_directed(underlying_graph)`.
  function default_data(
    index_type::Type{<:AbstractEdge},
    data_type::Type,
    indices_function::Function,
    underlying_graph::AbstractGraph,
    ::Nothing
  )
    out_indices = indices_function(underlying_graph)
    in_indices = reverse.(out_indices)
    # Interleave the indices.
    indices = collect(Iterators.flatten(zip(out_indices, in_indices)))
    return similar(Indices(indices), data_type)
  end

  # Custom dictionary-like constructor that only accepts Pair lists
  function data_dict(
    index_type::Type,
    data_type::Type,
    indices_function::Function,
    underlying_graph::AbstractGraph,
    data::Vector{<:Pair}
  )
    indices = index_type.(first.(data))
    values = convert(Vector{data_type}, last.(data))
    return Dictionary{index_type,data_type}(indices, values)
  end

  # Custom dictionary-like constructor that only accepts Pair lists
  function data_dict(
    index_type::Type,
    data_type::Type,
    indices_function::Function,
    underlying_graph::AbstractGraph,
    data::Vector
  )
    indices = indices_function(underlying_graph)
    values = convert(Vector{data_type}, data)
    return Dictionary{index_type,data_type}(indices, values)
  end

  function default_data(
    index_type::Type,
    data_type::Type,
    indices_function::Function,
    underlying_graph::AbstractGraph,
    init_data
  )
    data = data_dict(
      index_type,
      data_type,
      indices_function,
      underlying_graph,
      init_data
    )
    return default_data(
      index_type,
      data_type,
      indices_function,
      underlying_graph,
      data
    )
  end

  function set_data!(data::Dictionary, x, i)
    setindex!(data, x, i)
    return data
  end

  # XXX: Assumes `is_directed(underlying_graph)`.
  function set_data!(data::Dictionary{<:AbstractEdge}, x, i)
    setindex!(data, x, i)
    setindex!(data, reverse_direction(x), reverse(i))
    return data
  end

  function default_data(
    index_type::Type,
    data_type::Type,
    indices_function::Function,
    underlying_graph::AbstractGraph,
    init_data::Dictionary
  )
    data = default_data(
      index_type,
      data_type,
      indices_function,
      underlying_graph,
      nothing
    )
    # TODO: Use `merge`, once issues with `undef`
    # are worked out in `Dictionaries.jl`:
    # https://github.com/andyferris/Dictionaries.jl/issues/86
    for i in eachindex(init_data)
      if isassigned(init_data, i)
        #data[i] = init_data[i]
        set_data!(data, init_data[i], i)
      end
    end
    return data
  end

  data_type(::Nothing) = Any
  data_type(::Vector{T}) where {T} = T
  data_type(::Vector{Pair{S,T}}) where {S,T} = T

  function assign_data(graph::AbstractDataGraph; edge_data=Returns(nothing), vertex_data=Returns(nothing))
    graph = copy(graph)
    for v in vertices(graph)
      if !isassigned(graph, v) && !isnothing(vertex_data(v))
        graph[v] = vertex_data(v)
      end
    end
    for e in edges(graph)
      if !isassigned(graph, e) && !isnothing(edge_data(e))
        graph[e] = edge_data(e)
      end
    end
    return graph
  end

  #
  # Printing
  #

  function show(io::IO, mime::MIME"text/plain", graph::AbstractDataGraph)
    println(io, "DataGraph with $(nv(graph)) vertices:")
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

  #
  # DataGraph concrete type
  #

  # TODO: define VertexDataGraph, a graph with only data on the
  # vertices, and EdgeDataGraph, a graph with only data on the edges.
  struct DataGraph{VD,ED,V,E,G<:AbstractGraph} <: AbstractDataGraph{VD,ED,V,E}
    underlying_graph::G
    vertex_data::Dictionary{V,VD}
    edge_data::Dictionary{E,ED}
  end
  underlying_graph(graph::DataGraph) = getfield(graph, :underlying_graph)
  vertex_data(graph::DataGraph) = getfield(graph, :vertex_data)
  edge_data(graph::DataGraph) = getfield(graph, :edge_data)

  function DataGraph{VD,ED}(
    underlying_graph::G,
    vertex_data,
    edge_data
  ) where {VD,ED,G<:AbstractGraph}
    V = eltype(underlying_graph)
    E = edgetype(underlying_graph)
    vertex_data = default_data(V, VD, vertices, underlying_graph, vertex_data)
    edge_data = default_data(E, ED, edges, underlying_graph, edge_data)
    return DataGraph{VD,ED,V,E,G}(underlying_graph, vertex_data, edge_data)
  end

  copy(graph::DataGraph) = DataGraph(copy(underlying_graph(graph)), copy(vertex_data(graph)), copy(edge_data(graph)))

  function DataGraph{VD}(
    underlying_graph::AbstractGraph,
    vertex_data,
    edge_data
  ) where {VD}
    ED = data_type(edge_data)
    return DataGraph{VD,ED}(underlying_graph, vertex_data, edge_data)
  end

  function (DataGraph{VD,ED} where {VD})(
    underlying_graph::AbstractGraph,
    vertex_data,
    edge_data
  ) where {ED}
    VD = data_type(vertex_data)
    return DataGraph{VD,ED}(underlying_graph, vertex_data, edge_data)
  end

  function DataGraph(
    underlying_graph::AbstractGraph,
    vertex_data,
    edge_data
  )
    VD = data_type(vertex_data)
    ED = data_type(edge_data)
    return DataGraph{VD,ED}(underlying_graph, vertex_data, edge_data)
  end

  #
  # kwarg versions call arg versions
  #

  function DataGraph{VD,ED}(
    underlying_graph::AbstractGraph;
    vertex_data=nothing,
    edge_data=nothing
  ) where {VD,ED}
    return DataGraph{VD,ED}(underlying_graph, vertex_data, edge_data)
  end

  function DataGraph{VD}(
    underlying_graph::AbstractGraph;
    vertex_data=nothing,
    edge_data=nothing
  ) where {VD}
    return DataGraph{VD}(underlying_graph, vertex_data, edge_data)
  end

  function (DataGraph{VD,ED} where {VD})(
    underlying_graph::AbstractGraph;
    vertex_data=nothing,
    edge_data=nothing
  ) where {ED}
    return (DataGraph{VD,ED} where {VD})(underlying_graph, vertex_data, edge_data)
  end

  function DataGraph(
    underlying_graph::AbstractGraph;
    vertex_data=nothing,
    edge_data=nothing
  )
    return DataGraph(underlying_graph, vertex_data, edge_data)
  end

end # module DataGraphs
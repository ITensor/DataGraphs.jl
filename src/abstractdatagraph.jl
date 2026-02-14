using Dictionaries: Indices, set!, unset!
using Graphs: Graphs, AbstractEdge, IsDirected, a_star, add_edge!, add_vertex!, edges, ne,
    nv, steiner_tree, vertices
using NamedGraphs.GraphsExtensions: GraphsExtensions, add_vertices!, arrange_edge,
    incident_edges, is_edge_arranged, similar_graph, vertextype
using NamedGraphs.OrdinalIndexing: OrdinalSuffixedInteger
using NamedGraphs.SimilarType: similar_type
using NamedGraphs: NamedGraphs, AbstractEdges, AbstractNamedEdge, AbstractNamedGraph,
    AbstractVertices, position_graph_type
using SimpleTraits: SimpleTraits, @traitfn, Not

is_underlying_graph(::Type{<:AbstractNamedGraph}) = true

abstract type AbstractDataGraph{V, VD, ED} <: AbstractNamedGraph{V} end

vertex_data_type(::Type{<:AbstractGraph}) = Any
edge_data_type(::Type{<:AbstractGraph}) = Any

vertex_data_type(::Type{<:AbstractDataGraph{V, VD, ED}}) where {V, VD, ED} = VD
edge_data_type(::Type{<:AbstractDataGraph{V, VD, ED}}) where {V, VD, ED} = ED

# Minimal interface
# TODO: Define for `AbstractGraph` as a `DataGraphInterface`.
underlying_graph(::AbstractDataGraph) = not_implemented()

is_vertex_assigned(::AbstractDataGraph, vertex) = not_implemented()
is_edge_assigned(::AbstractDataGraph, edge) = not_implemented()

get_vertex_data(::AbstractDataGraph, vertex) = not_implemented()
get_edge_data(::AbstractDataGraph, edge) = not_implemented()

set_vertex_data!(::AbstractDataGraph, data, vertex) = not_implemented()
set_edge_data!(::AbstractDataGraph, data, edge) = not_implemented()

# Quasi-derived interface; only required if inference fails

underlying_graph_type(T::Type{<:AbstractGraph}) = Base.promote_op(underlying_graph, T)

function get_vertices_data(g::AbstractGraph, vertices)
    return map(v -> getindex(g, v), Indices(vertices))
end
function get_edges_data(g::AbstractGraph, edges)
    return map(e -> getindex(g, e), Indices(edges))
end

Graphs.has_vertex(g::AbstractDataGraph, vertex) = has_vertex(underlying_graph(g), vertex)
Graphs.has_edge(g::AbstractDataGraph, edge) = has_edge(underlying_graph(g), edge)
function Graphs.has_edge(g::AbstractDataGraph, edge::AbstractNamedEdge)
    return has_edge(underlying_graph(g), edge)
end

vertex_data(dg::AbstractGraph) = VertexDataView(dg)
edge_data(dg::AbstractGraph) = EdgeDataView(dg)

function assigned_vertices(graph::AbstractGraph)
    return Indices(filter(v -> isassigned(graph, v), vertices(graph)))
end
function assigned_edges(graph::AbstractGraph)
    return Indices(filter(e -> isassigned(graph, e), edges(graph)))
end

function Graphs.edgetype(graph::AbstractDataGraph)
    return Graphs.edgetype(underlying_graph(graph))
end
function Graphs.edgetype(graph_type::Type{<:AbstractDataGraph})
    return edgetype(underlying_graph_type(graph_type))
end
function Graphs.is_directed(graph_type::Type{<:AbstractDataGraph})
    return Graphs.is_directed(underlying_graph_type(graph_type))
end

underlying_graph_type(graph::AbstractGraph) = typeof(underlying_graph(graph))
vertex_data_type(graph::AbstractGraph) = vertex_data_type(typeof(graph))
edge_data_type(graph::AbstractGraph) = edge_data_type(typeof(graph))

function NamedGraphs.position_graph_type(type::Type{<:AbstractDataGraph})
    return position_graph_type(underlying_graph_type(type))
end

Base.zero(graph_type::Type{<:AbstractDataGraph}) = similar_graph(graph_type)

# Graphs overloads
function Graphs.vertices(graph::AbstractDataGraph)
    return Graphs.vertices(underlying_graph(graph))
end
function Graphs.add_vertex!(graph::AbstractDataGraph, vertex)
    Graphs.add_vertex!(underlying_graph(graph), vertex)
    return graph
end

# Simple NamedGraphs overloads
for f in [
        :(NamedGraphs.ordered_vertices),
        :(NamedGraphs.vertex_positions),
        :(NamedGraphs.position_graph),
    ]
    @eval begin
        $f(graph::AbstractDataGraph) = $f(underlying_graph(graph))
    end
end

# These cannot be known abstractly.
GraphsExtensions.directed_graph_type(::AbstractDataGraph) = not_implemented()
GraphsExtensions.undirected_graph_type(::AbstractDataGraph) = not_implemented()

# Thase canot be implemented abstractly.
function GraphsExtensions.convert_vertextype(vertextype::Type, graph::AbstractDataGraph)
    return not_implemented()
end

# Fix for ambiguity error with `AbstractGraph` version
function Graphs.degree(graph::AbstractDataGraph, vertex::Integer)
    return Graphs.degree(underlying_graph(graph), vertex)
end

# Fix for ambiguity error with `AbstractGraph` version
function Graphs.dijkstra_shortest_paths(
        graph::AbstractDataGraph, vertices::Vector{<:Integer}
    )
    return Graphs.dijkstra_shortest_paths(underlying_graph(graph), vertices)
end

# Fix for ambiguity error with `AbstractGraph` version
function Graphs.eccentricity(graph::AbstractDataGraph, distmx::AbstractMatrix)
    return Graphs.eccentricity(underlying_graph(graph), distmx)
end

# Fix for ambiguity error with `AbstractGraph` version
function Graphs.indegree(graph::AbstractDataGraph, vertex::Integer)
    return indegree(underlying_graph(graph), vertex)
end

# Fix for ambiguity error with `AbstractGraph` version
function Graphs.outdegree(graph::AbstractDataGraph, vertex::Integer)
    return outdegree(underlying_graph(graph), vertex)
end

# Fix for ambiguity error with `AbstractGraph` version
function Graphs.a_star(
        graph::AbstractDataGraph, source::Integer, destination::Integer, args...
    )
    return a_star(underlying_graph(graph), source, destination, args...)
end

# Fix for ambiguity error with `AbstractGraph` version
@traitfn function Graphs.steiner_tree(
        graph::AbstractDataGraph::(!IsDirected), term_vert::Vector{<:Integer}, args...
    )
    return steiner_tree(underlying_graph(graph), term_vert, args...)
end

@traitfn GraphsExtensions.directed_graph(graph::AbstractDataGraph::IsDirected) = graph

reverse_data_direction(graph::AbstractDataGraph, data) = data
function reverse_data_direction(graph::AbstractDataGraph, edge::AbstractEdge, data)
    return is_edge_arranged(graph, edge) ? data : reverse_data_direction(graph, data)
end

@traitfn function GraphsExtensions.directed_graph(graph::AbstractDataGraph::(!IsDirected))
    digraph = directed_graph(typeof(graph))(directed_graph(underlying_graph(graph)))
    for v in vertices(graph)
        # TODO: Only loop over `keys(vertex_data(graph))`
        if isassigned(graph, v)
            digraph[v] = graph[v]
        end
    end
    for e in edges(graph)
        # TODO: Only loop over `keys(edge_data(graph))`
        # TODO: Are these needed?
        add_edge!(digraph, e)
        add_edge!(digraph, reverse(e))
        if isassigned(graph, e)
            digraph[e] = graph[e]
            digraph[reverse(e)] = reverse_data_direction(graph, graph[e])
        end
    end
    return digraph
end

function GraphsExtensions.rename_vertices(f::Function, graph::AbstractDataGraph)

    # Uses the two-argument `similar_graph` method so the new graph has correct vertex type
    renamed_vertices = map(f, vertices(graph))
    renamed_graph = similar_graph(graph, eltype(renamed_vertices))

    add_vertices!(renamed_graph, renamed_vertices)

    for vertex in vertices(graph)
        if isassigned(graph, vertex)
            renamed_graph[f(vertex)] = graph[vertex]
        end
    end

    for edge in edges(graph)
        renamed_edge = rename_vertices(f, edge)
        add_edge!(renamed_graph, renamed_edge)
        if isassigned(graph, edge)
            renamed_graph[renamed_edge] = graph[edge]
        end
    end

    return renamed_graph
end

function Base.reverse(graph::AbstractDataGraph)
    reversed_graph = similar_graph(graph)
    for v in vertices(graph)
        add_vertex!(reversed_graph, v)
        if isassigned(graph, v)
            reversed_graph[v] = graph[v]
        end
    end
    for e in edges(graph)
        add_edge!(reversed_graph, reverse(e))
        if isassigned(graph, e)
            reversed_graph[reverse(e)] = graph[e]
        end
    end
    return reversed_graph
end

function Graphs.merge_vertices(
        graph::AbstractDataGraph,
        merge_vertices;
        merge_data = (x, y) -> y,
        merge_vertex_data = merge_data,
        merge_edge_data = merge_data,
        kwargs...
    )
    return not_implemented()
end

function Graphs.merge_vertices!(
        graph::AbstractDataGraph,
        merge_vertices;
        merge_data = (x, y) -> y,
        merge_vertex_data = merge_data,
        merge_edge_data = merge_data,
        kwargs...
    )
    return not_implemented()
end

# Union the vertices and edges of the graphs and
# merge the vertex and edge metadata.
function Base.union(
        graph1::AbstractDataGraph,
        graph2::AbstractDataGraph;
        merge_data = (x, y) -> y,
        merge_vertex_data = merge_data,
        merge_edge_data = merge_data
    )
    underlying_graph_union = union(underlying_graph(graph1), underlying_graph(graph2))
    vertex_data_merge = mergewith(
        merge_vertex_data,
        assigned_vertex_data(graph1),
        assigned_vertex_data(graph2)
    )
    edge_data_merge =
        mergewith(merge_edge_data, assigned_edge_data(graph1), assigned_edge_data(graph2))
    # TODO: Convert to `promote_type(typeof(graph1), typeof(graph2))`
    return _DataGraph(underlying_graph_union, vertex_data_merge, edge_data_merge)
end

function Base.union(
        graph1::AbstractDataGraph,
        graph2::AbstractDataGraph,
        graph3::AbstractDataGraph,
        graphs_tail::AbstractDataGraph...;
        kwargs...
    )
    return union(union(graph1, graph2; kwargs...), graph3, graphs_tail...; kwargs...)
end

function Graphs.rem_vertex!(graph::AbstractDataGraph, vertex)
    Graphs.rem_vertex!(underlying_graph(graph), vertex)
    return graph
end
function Graphs.rem_edge!(graph::AbstractDataGraph, edge)
    Graphs.rem_edge!(underlying_graph(graph), edge)
    return graph
end

# Fix ambiguity with:
# Graphs.neighbors(graph::AbstractGraph, v::Integer)
function Graphs.neighbors(graph::AbstractDataGraph, v::Integer)
    return Graphs.neighbors(underlying_graph(graph), v)
end

# Fix ambiguity with:
# Graphs.bfs_tree(graph::AbstractGraph, s::Integer; dir)
function Graphs.bfs_tree(graph::AbstractDataGraph, s::Integer; kwargs...)
    return Graphs.bfs_tree(underlying_graph(graph), s; kwargs...)
end

# Fix ambiguity with:
# Graphs.dfs_tree(graph::AbstractGraph, s::Integer; dir)
function Graphs.dfs_tree(graph::AbstractDataGraph, s::Integer; kwargs...)
    return Graphs.dfs_tree(underlying_graph(graph), s; kwargs...)
end

function map_vertex_data(f, graph::AbstractGraph; vertices = nothing)
    new_graph = copy(graph)
    vs = isnothing(vertices) ? Graphs.vertices(graph) : vertices
    for v in vs
        new_graph[v] = f(graph[v])
    end
    return new_graph
end

function map_edge_data(f, graph::AbstractGraph; edges = nothing)
    new_graph = copy(graph)
    es = isnothing(edges) ? Graphs.edges(graph) : edges
    for e in es
        if isassigned(graph, e)
            new_graph[e] = f(graph[e])
        end
    end
    return new_graph
end

function map_data(f, graph::AbstractGraph; vertices = nothing, edges = nothing)
    graph = map_vertex_data(f, graph; vertices)
    return map_edge_data(f, graph; edges)
end

Base.get!(graph::AbstractDataGraph, key, default) = get!(() -> default, graph, key)
function Base.get!(default::Base.Callable, graph::AbstractDataGraph, key)
    if isassigned(graph, key)
        return graph[key]
    else
        return graph[key] = default()
    end
end
Base.get(graph::AbstractDataGraph, key, default) = get(() -> default, graph, key)
function Base.get(default::Base.Callable, graph::AbstractDataGraph, key)
    if isassigned(graph, key)
        return graph[key]
    else
        return default()
    end
end

function NamedGraphs.induced_subgraph_from_vertices(graph::AbstractDataGraph, subvertices)
    return induced_subgraph_datagraph(graph, subvertices)
end
function induced_subgraph_datagraph(graph::AbstractDataGraph, subvertices)
    underlying_subgraph, vlist =
        Graphs.induced_subgraph(underlying_graph(graph), subvertices)

    subgraph = similar_graph(graph, underlying_subgraph)

    for v in vertices(subgraph)
        if isassigned(graph, v)
            subgraph[v] = graph[v]
        end
    end
    for e in edges(subgraph)
        if isassigned(graph, e)
            subgraph[e] = graph[e]
        end
    end
    return subgraph, vlist
end

#
# Printing
#

function Base.show(io::IO, mime::MIME"text/plain", graph::AbstractDataGraph)
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

Base.show(io::IO, graph::AbstractDataGraph) = show(io, MIME"text/plain"(), graph)

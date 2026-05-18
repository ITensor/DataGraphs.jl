using Graphs: dst, has_edge, rem_edge!, rem_vertex!, src
using NamedGraphs: NamedEdge, NamedGraph, ordered_vertices, position_graph, vertex_positions

struct EdgeDataGraph{E <: NamedEdge{V} where {V}, T, V} <: AbstractEdgeDataGraph{E, T, V}
    underlying_graph::NamedGraph{V}
    edge_data::Dictionary{E, T}
    function EdgeDataGraph{E, T, V}(
            ::UndefInitializer,
            vertices
        ) where {V, E <: NamedEdge{V}, T}
        graph = NamedGraph{V}(vertices)
        edge_data = Dictionary{E, T}()
        return new{E, T, V}(graph, edge_data)
    end
end

EdgeDataGraph(data) = EdgeDataGraph{keytype(data)}(data)
EdgeDataGraph{I}(data) where {I} = EdgeDataGraph{I, valtype(data)}(data)
EdgeDataGraph{I, T}(data) where {I, T} = EdgeDataGraph{I, T, vertextype(I)}(data)

Graphs.is_directed(::Type{<:EdgeDataGraph}) = false

struct EdgeDataDiGraph{E <: NamedEdge{V} where {V}, T, V} <: AbstractEdgeDataGraph{E, T, V}
    underlying_graph::NamedDiGraph{V}
    edge_data::Dictionary{E, T}
    function EdgeDataDiGraph{E, T, V}(
            ::UndefInitializer,
            vertices
        ) where {V, E <: NamedEdge{V}, T}
        graph = NamedDiGraph{V}(vertices)
        edge_data = Dictionary{E, T}()
        return new{E, T, V}(graph, edge_data)
    end
end

EdgeDataDiGraph(data) = EdgeDataDiGraph{keytype(data)}(data)
EdgeDataDiGraph{I}(data) where {I} = EdgeDataDiGraph{I, valtype(data)}(data)
EdgeDataDiGraph{I, T}(data) where {I, T} = EdgeDataDiGraph{I, T, vertextype(I)}(data)

Graphs.is_directed(::Type{<:EdgeDataDiGraph}) = true

for GType in (:EdgeDataGraph, :EdgeDataDiGraph)
    @eval begin
        function $GType{E, T, V}(data) where {V, E <: NamedEdge{V}, T}
            edges = keys(data)
            vertices = union(src.(edges), dst.(edges))
            graph = $GType{E, T, V}(undef, vertices)
            copyto!(graph, data)
            return graph
        end
    end
end

# ====================================== Graphs.jl ======================================= #

for GType in (:EdgeDataGraph, :EdgeDataDiGraph)
    @eval begin
        Graphs.edgetype(::Type{<:$GType{I, T, V}}) where {I, T, V} = I

        function Graphs.has_vertex(graph::$GType, vertex)
            return has_vertex(graph.underlying_graph, vertex)
        end
        function Graphs.has_edge(graph::$GType, edge::NamedEdge)
            return has_edge(graph.underlying_graph, edge)
        end

        function Graphs.rem_edge!(graph::$GType, edge)
            unset!(graph.edge_data, edge)
            rem_edge!(graph.underlying_graph, edge)
            return graph
        end

        function Graphs.rem_vertex!(graph::$GType, vertex)
            for edge in incident_edges(graph, vertex)
                unset!(graph.edge_data, edge)
            end
            rem_vertex!(graph.underlying_graph, vertex)
            return graph
        end

        Graphs.vertices(graph::$GType) = vertices(graph.underlying_graph)
    end
end

# ==================================== NamedGraphs.jl ==================================== #

for GType in (:EdgeDataGraph, :EdgeDataDiGraph)
    @eval begin
        function NamedGraphs.vertex_positions(graph::$GType)
            return vertex_positions(graph.underlying_graph)
        end

        function NamedGraphs.ordered_vertices(graph::$GType)
            return ordered_vertices(graph.underlying_graph)
        end

        function NamedGraphs.position_graph(graph::$GType)
            return position_graph(graph.underlying_graph)
        end
    end
end

# ==================================== DataGraphs.jl ===================================== #

for GType in (:EdgeDataGraph, :EdgeDataDiGraph)
    @eval begin
        edge_data_type(::Type{<:$GType{I, T, V}}) where {I, T, V} = T

        function set_edge_data!(graph::$GType, data, edge)
            graph.edge_data[edge] = data
            return graph
        end

        get_edge_data(graph::$GType, edge) = graph.edge_data[edge]

        is_vertex_assigned(::$GType, _vertex) = false
        is_edge_assigned(graph::$GType, edge) = isassigned(graph.edge_data, edge)
    end
end

# =================================== Dictionaries.jl ==================================== #

for GType in (:EdgeDataGraph, :EdgeDataDiGraph)
    @eval begin
        Dictionaries.isinsertable(::Type{<:$GType}, _edge) = true
    end
end

function insert_edge_data!(graph::AbstractEdgeDataGraph, edge::AbstractEdge, data)
    if has_edge(graph, edge)
        throw(IndexError("Graph already contains edge $edge"))
    else
        add_edge!(graph.underlying_graph, edge)
        insert!(graph.edge_data, edge, data)
    end
    return graph
end

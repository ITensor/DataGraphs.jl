using Graphs: dst, has_edge, rem_edge!, rem_vertex!, src
using NamedGraphs: NamedEdge, NamedGraph, ordered_vertices, position_graph, vertex_positions

struct EdgeDataGraph{T, V} <: AbstractEdgeDataGraph{T, V}
    underlying_graph::NamedGraph{V}
    edge_data::Dictionary{NamedEdge{V}, T}
    function EdgeDataGraph{T, V}(
            ::UndefInitializer,
            vertices
        ) where {T, V}
        graph = NamedGraph{V}(vertices)
        edge_data = Dictionary{NamedEdge{V}, T}()
        return new{T, V}(graph, edge_data)
    end
end

Graphs.is_directed(::Type{<:EdgeDataGraph}) = false

struct EdgeDataDiGraph{T, V} <: AbstractEdgeDataGraph{T, V}
    underlying_graph::NamedDiGraph{V}
    edge_data::Dictionary{NamedEdge{V}, T}
    function EdgeDataDiGraph{T, V}(
            ::UndefInitializer,
            vertices
        ) where {T, V}
        graph = NamedDiGraph{V}(vertices)
        edge_data = Dictionary{NamedEdge{V}, T}()
        return new{T, V}(graph, edge_data)
    end
end

Graphs.is_directed(::Type{<:EdgeDataDiGraph}) = true

for GType in (:EdgeDataGraph, :EdgeDataDiGraph)
    @eval begin
        $GType(::UndefInitializer, vertices) = $GType{Any}(undef, vertices)
        function $GType{T}(::UndefInitializer, vertices) where {T}
            return $GType{T, eltype(vertices)}(undef, vertices)
        end

        $GType(data) = $GType{valtype(data)}(data)
        $GType{T}(data) where {T} = $GType{T, vertextype(keytype(data))}(data)

        function $GType{T, V}(data) where {T, V}
            edges = keys(data)
            vertices = union(src.(edges), dst.(edges))
            graph = $GType{T, V}(undef, vertices)
            copyto!(graph, data)
            return graph
        end
    end
end

# ====================================== Graphs.jl ======================================= #

for GType in (:EdgeDataGraph, :EdgeDataDiGraph)
    @eval begin
        Graphs.edgetype(::Type{<:$GType{T, V}}) where {T, V} = NamedEdge{V}

        function Graphs.add_vertex!(graph::$GType, vertex)
            return add_vertex!(graph.underlying_graph, vertex)
        end
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
        edge_data_type(::Type{<:$GType{T}}) where {T} = T

        function set_edge_data!(graph::$GType, data, edge)
            # Edges `upsert` if vertices are present.
            has_edge(graph, edge) || add_edge!(graph.underlying_graph, edge)
            set!(graph.edge_data, edge, data)
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
        Dictionaries.isinsertable(::$GType) = true
    end
end

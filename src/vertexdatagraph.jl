using Dictionaries: Dictionary, set!
using Graphs: Graphs, has_edge, rem_vertex!
using NamedGraphs:
    NamedDiGraph, NamedEdge, NamedGraph, ordered_vertices, position_graph, vertex_positions

struct VertexDataGraph{T, V} <: AbstractVertexDataGraph{T, V}
    underlying_graph::NamedGraph{V}
    vertex_data::Dictionary{V, T}
    function VertexDataGraph{T, V}(
            ::UndefInitializer,
            vertices
        ) where {T, V}
        graph = NamedGraph{V}(vertices)
        vertex_data = Dictionary{V, T}()
        return new{T, V}(graph, vertex_data)
    end
end

struct VertexDataDiGraph{T, V} <: AbstractVertexDataGraph{T, V}
    underlying_graph::NamedDiGraph{V}
    vertex_data::Dictionary{V, T}
    function VertexDataDiGraph{T, V}(
            ::UndefInitializer,
            vertices
        ) where {T, V}
        graph = NamedDiGraph{V}(vertices)
        vertex_data = Dictionary{V, T}()
        return new{T, V}(graph, vertex_data)
    end
end

Graphs.is_directed(::Type{<:VertexDataGraph}) = false
Graphs.is_directed(::Type{<:VertexDataDiGraph}) = true

for GType in (:VertexDataGraph, :VertexDataDiGraph)
    @eval begin
        $GType(::UndefInitializer, vertices) = $GType{Any}(undef, vertices)
        function $GType{T}(::UndefInitializer, vertices) where {T}
            return $GType{T, eltype(vertices)}(undef, vertices)
        end

        $GType(data) = $GType{valtype(data)}(data)
        $GType{T}(data) where {T} = $GType{T, keytype(data)}(data)

        function $GType{T, V}(data) where {T, V}
            vertices = keys(data)
            cache = $GType{T, V}(undef, vertices)
            return copyto!(cache, data)
        end

        function Base.:(==)(dg1::$GType, dg2::$GType)
            return dg1.underlying_graph == dg2.underlying_graph &&
                dg1.vertex_data == dg2.vertex_data
        end
    end
end

# ====================================== Graphs.jl ======================================= #

for GType in (:VertexDataGraph, :VertexDataDiGraph)
    @eval begin
        Graphs.edgetype(::Type{<:$GType{T, V}}) where {T, V} = NamedEdge{V}

        function Graphs.add_vertex!(graph::$GType, vertex)
            return throw(
                ArgumentError(
                    "cannot add data-free vertices to $GType; use `insert!`, `setindex!` or `set!` instead"
                )
            )
        end

        function Graphs.add_edge!(graph::$GType, edge::NamedEdge)
            return add_edge!(graph.underlying_graph, edge)
        end

        function Graphs.rem_vertex!(graph::$GType, vertex)
            unset!(graph.vertex_data, vertex)
            rem_vertex!(graph.underlying_graph, vertex)
            return graph
        end

        function Graphs.rem_edge!(graph::$GType, vertex)
            rem_edge!(graph.underlying_graph, vertex)
            return graph
        end

        Graphs.vertices(graph::$GType) = vertices(graph.underlying_graph)
    end
end

# ==================================== NamedGraphs.jl ==================================== #

for GType in (:VertexDataGraph, :VertexDataDiGraph)
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

        function NamedGraphs.similar_graph(graph::$GType, T::Type, vertices::Vertices)
            new_graph = $GType{T}(undef, collect(vertices))
            return new_graph
        end

        NamedGraphs.similar_graph(T::Type{<:$GType}, vertices) = T(undef, vertices)
    end
end

# ==================================== DataGraphs.jl ===================================== #

for GType in (:VertexDataGraph, :VertexDataDiGraph)
    @eval begin
        vertex_data_type(::Type{<:$GType{T}}) where {T} = T

        function set_vertex_data!(graph::$GType, data, vertex)
            # We use an upsert here as we have already checked if the vertex (i.e. key) exists,
            # but it might not exist in the internal `Dictionary`, so add it if not.
            set!(graph.vertex_data, vertex, data)
            return graph
        end

        get_vertex_data(graph::$GType, vertex) = graph.vertex_data[vertex]

        is_vertex_assigned(graph::$GType, vertex) = isassigned(graph.vertex_data, vertex)
        is_edge_assigned(::$GType, _edge) = false
    end
end

# =================================== Dictionaries.jl ==================================== #

for GType in (:VertexDataGraph, :VertexDataDiGraph)
    @eval begin
        Dictionaries.isinsertable(::$GType) = true

        function insert_vertex_data!(graph::$GType, vertex, data)
            add_vertex!(graph.underlying_graph, vertex)
            insert!(graph.vertex_data, vertex, data)
            return graph
        end
    end
end

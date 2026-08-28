using Graphs: dst, has_edge, rem_edge!, rem_vertex!, src
using NamedGraphs: NamedEdge, NamedGraph, decoded_vertex, encoded_graph, encoded_vertex

struct EdgeDataGraph{T, V} <: AbstractEdgeDataGraph{T, V}
    underlying_graph::NamedGraph{V}
    edge_data::Dictionary{NamedEdge{V}, T}
    function EdgeDataGraph{T, V}(::UndefInitializer, vertices) where {T, V}
        graph = NamedGraph{V}(vertices)
        edge_data = Dictionary{NamedEdge{V}, T}()
        return new{T, V}(graph, edge_data)
    end
end

Graphs.is_directed(::Type{<:EdgeDataGraph}) = false

struct EdgeDataDiGraph{T, V} <: AbstractEdgeDataGraph{T, V}
    underlying_graph::NamedDiGraph{V}
    edge_data::Dictionary{NamedEdge{V}, T}
    function EdgeDataDiGraph{T, V}(::UndefInitializer, vertices) where {T, V}
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
            edges = NamedEdge{V}.(keys(data))
            vertices = union(src.(edges), dst.(edges))
            graph = $GType{T, V}(undef, vertices)
            add_edges!(graph.underlying_graph, edges)
            copyto!(graph, data)
            return graph
        end

        function Base.:(==)(dg1::$GType, dg2::$GType)
            return dg1.underlying_graph == dg2.underlying_graph &&
                dg1.edge_data == dg2.edge_data
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

        function Graphs.add_edge!(graph::$GType, edge)
            G = esc($GType)
            throw(
                ArgumentError(
                    "cannot add data-free edges to $G; use `insert!`, `setindex!` or `set!` instead"
                )
            )
            return nothing
        end

        function Graphs.rem_vertex!(graph::$GType, vertex)
            for edge in incident_edges(graph, vertex)
                unset!(graph.edge_data, edge)
            end
            return rem_vertex!(graph.underlying_graph, vertex)
        end

        function Graphs.rem_edge!(graph::$GType, edge)
            unset!(graph.edge_data, edge)
            return rem_edge!(graph.underlying_graph, edge)
        end

        Graphs.vertices(graph::$GType) = vertices(graph.underlying_graph)
    end
end

# ==================================== NamedGraphs.jl ==================================== #

for GType in (:EdgeDataGraph, :EdgeDataDiGraph)
    @eval begin
        function NamedGraphs.encoded_vertex(graph::$GType, vertex)
            return encoded_vertex(graph.underlying_graph, vertex)
        end

        function NamedGraphs.decoded_vertex(graph::$GType, code::Integer)
            return decoded_vertex(graph.underlying_graph, code)
        end

        function NamedGraphs.encoded_graph(graph::$GType)
            return encoded_graph(graph.underlying_graph)
        end

        function NamedGraphs.similar_graph(graph::$GType, T::Type, vertices)
            return $GType{T}(undef, vertices)
        end

        # We know how to add edges keys for these particurly concrete types
        function NamedGraphs.similar_graph(graph::$GType, T::Type)
            new_graph = similar_graph(graph, T, vertices(graph))
            add_edges!(new_graph.underlying_graph, edges(graph))
            return new_graph
        end

        NamedGraphs.similar_graph(T::Type{<:$GType}, vertices) = T(undef, vertices)
    end
end

# ==================================== DataGraphs.jl ===================================== #

for GType in (:EdgeDataGraph, :EdgeDataDiGraph)
    @eval begin
        edge_data_type(::Type{<:$GType{T}}) where {T} = T

        function set_edge_data!(graph::$GType, data, edge)
            # We use an upsert here as we have already checked if the edge (i.e. key) exists,
            # but it might not exist in the internal `Dictionary`, so add it if not.
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

        function insert_edge_data!(graph::$GType, vertex, data)
            add_edge!(graph.underlying_graph, vertex)
            insert!(graph.edge_data, vertex, data)
            return graph
        end
    end
end

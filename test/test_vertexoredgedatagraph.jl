using DataGraphs: DataGraphs, EdgeDataDiGraph, EdgeDataGraph, EdgeDataView,
    VertexDataDiGraph, VertexDataGraph, VertexDataView, edge_data, edge_data_type,
    underlying_graph, vertex_data, vertex_data_type
using Dictionaries: AbstractDictionary, Dictionary, Indices
using Graphs: AbstractGraph, add_edge!, dst, edges, edgetype, has_edge, has_vertex,
    is_directed, ne, nv, rem_edge!, rem_vertex!, src, vertices
using NamedGraphs.GraphsExtensions: vertextype
using NamedGraphs:
    NamedDiGraph, NamedEdge, NamedGraph, ordered_vertices, position_graph, vertex_positions
using Test: @test, @testset

@testset "VertexDataGraph and EdgeDataGraph" begin
    @testset "VertexDataGraph" begin
        @testset "undef constructor" begin
            g = VertexDataGraph{Int, String}(undef, [1, 2, 3])
            @test g isa VertexDataGraph{Int, String}
            @test nv(g) == 3
            @test ne(g) == 0
            @test has_vertex(g, 1)
            @test has_vertex(g, 2)
            @test has_vertex(g, 3)
            @test !has_vertex(g, 4)
            @test Set(collect(vertices(g))) == Set([1, 2, 3])
        end

        @testset "data constructor" begin
            data = Dictionary([1, 2, 3], ["V1", "V2", "V3"])
            g = VertexDataGraph(data)
            @test g isa VertexDataGraph{Int, String}
            @test nv(g) == 3
            @test isassigned(g, 1)
            @test isassigned(g, 2)
            @test isassigned(g, 3)
            @test g[1] == "V1"
            @test g[2] == "V2"
            @test g[3] == "V3"
        end

        @testset "Graphs.jl interface" begin
            g = VertexDataGraph{Int, String}(undef, [1, 2, 3])
            @test !is_directed(VertexDataGraph)
            @test !is_directed(g)
            @test vertextype(g) == Int
            @test edgetype(g) == NamedEdge{Int}

            add_edge!(g, NamedEdge(1, 2))
            add_edge!(g, NamedEdge(2, 3))
            @test ne(g) == 2
            @test has_edge(g, NamedEdge(1, 2))
            @test has_edge(g, NamedEdge(2, 3))
            @test !has_edge(g, NamedEdge(1, 3))
            @test length(collect(edges(g))) == 2

            rem_edge!(g, NamedEdge(1, 2))
            @test ne(g) == 1
            @test !has_edge(g, NamedEdge(1, 2))
        end

        @testset "rem_vertex!" begin
            g = VertexDataGraph{Int, String}(undef, [1, 2, 3])
            add_edge!(g, NamedEdge(1, 2))
            rem_vertex!(g, 1)
            @test !has_vertex(g, 1)
            @test nv(g) == 2
            @test ne(g) == 0
        end

        @testset "DataGraphs interface" begin
            g = VertexDataGraph{Int, String}(undef, [1, 2, 3])
            @test underlying_graph(g) isa NamedGraph{Int}
            @test vertex_data_type(g) == String
            @test vertex_data_type(VertexDataGraph{Int, String}) == String
            @test !isassigned(g, 1)
            @test !isassigned(g, 2)
            @test !isassigned(g, 3)
        end

        @testset "setindex! and getindex" begin
            g = VertexDataGraph{Int, String}(undef, [1, 2, 3])
            g[1] = "V1"
            g[2] = "V2"
            g[3] = "V3"
            @test isassigned(g, 1)
            @test isassigned(g, 2)
            @test isassigned(g, 3)
            @test g[1] == "V1"
            @test g[2] == "V2"
            @test g[3] == "V3"
        end

        @testset "NamedGraphs interface" begin
            g = VertexDataGraph{Int, String}(undef, [1, 2, 3])
            @test underlying_graph(g) isa NamedGraph{Int}
            @test position_graph(g) isa AbstractGraph
            @test ordered_vertices(g) isa AbstractVector
            @test vertex_positions(g) isa AbstractDictionary
        end

        @testset "Dictionaries interface" begin
            g = VertexDataGraph{Int, String}(undef, [1, 2, 3])
            @test keytype(g) == Int
            @test valtype(g) == String
            @test keys(g) isa Indices
            @test length(g) == 3
            @test vertex_data(g) isa VertexDataView
        end
    end

    @testset "VertexDataDiGraph" begin
        @testset "undef constructor" begin
            g = VertexDataDiGraph{Int, String}(undef, [1, 2, 3])
            @test g isa VertexDataDiGraph{Int, String}
            @test nv(g) == 3
            @test ne(g) == 0
            @test has_vertex(g, 1)
            @test !has_vertex(g, 4)
        end

        @testset "data constructor" begin
            data = Dictionary([1, 2, 3], ["V1", "V2", "V3"])
            g = VertexDataDiGraph(data)
            @test g isa VertexDataDiGraph{Int, String}
            @test nv(g) == 3
            @test g[1] == "V1"
            @test g[2] == "V2"
            @test g[3] == "V3"
        end

        @testset "directed graph" begin
            g = VertexDataDiGraph{Int, String}(undef, [1, 2, 3])
            @test is_directed(VertexDataDiGraph)
            @test is_directed(g)
            @test underlying_graph(g) isa NamedDiGraph{Int}
        end

        @testset "directed edges" begin
            g = VertexDataDiGraph{Int, String}(undef, [1, 2, 3])
            add_edge!(g, NamedEdge(1, 2))
            @test has_edge(g, NamedEdge(1, 2))
            @test !has_edge(g, NamedEdge(2, 1))
            @test ne(g) == 1
        end

        @testset "DataGraphs interface" begin
            g = VertexDataDiGraph{Int, String}(undef, [1, 2, 3])
            @test vertex_data_type(g) == String
            @test vertex_data_type(VertexDataDiGraph{Int, String}) == String
            @test vertextype(g) == Int
            @test edgetype(g) == NamedEdge{Int}
        end

        @testset "Dictionaries interface" begin
            g = VertexDataDiGraph{Int, String}(undef, [1, 2, 3])
            @test keytype(g) == Int
            @test valtype(g) == String
            @test keys(g) isa Indices
            @test length(g) == 3
            @test vertex_data(g) isa VertexDataView
        end
    end

    @testset "EdgeDataGraph" begin
        E = NamedEdge{Int}

        @testset "undef constructor" begin
            g = EdgeDataGraph{E, String, Int}(undef, [1, 2, 3])
            @test g isa EdgeDataGraph{E, String, Int}
            @test nv(g) == 3
            @test ne(g) == 0
        end

        @testset "data constructor" begin
            data = Dictionary([NamedEdge(1, 2), NamedEdge(2, 3)], ["E12", "E23"])
            g = EdgeDataGraph(data)
            @test g isa EdgeDataGraph{E, String, Int}
            @test nv(g) == 3
            @test ne(g) == 2
            @test isassigned(g, NamedEdge(1, 2))
            @test isassigned(g, NamedEdge(2, 3))
            @test g[NamedEdge(1, 2)] == "E12"
            @test g[NamedEdge(2, 3)] == "E23"
        end

        @testset "Graphs.jl interface" begin
            g = EdgeDataGraph{E, String, Int}(undef, [1, 2, 3])
            @test !is_directed(EdgeDataGraph)
            @test !is_directed(g)
            @test has_vertex(g, 1)
            @test has_vertex(g, 2)
            @test !has_vertex(g, 4)
            @test edgetype(g) == E

            add_edge!(g, NamedEdge(1, 2))
            add_edge!(g, NamedEdge(2, 3))
            @test ne(g) == 2
            @test has_edge(g, NamedEdge(1, 2))
            @test has_edge(g, NamedEdge(2, 3))
            @test !has_edge(g, NamedEdge(1, 3))
        end

        @testset "DataGraphs interface" begin
            g = EdgeDataGraph{E, String, Int}(undef, [1, 2, 3])
            @test edge_data_type(EdgeDataGraph{E, String, Int}) == String
            @test edge_data_type(g) == String
            @test !isassigned(g, 1)
            @test !isassigned(g, NamedEdge(1, 2))
        end

        @testset "setindex! and getindex" begin
            data = Dictionary([NamedEdge(1, 2), NamedEdge(2, 3)], ["E12", "E23"])
            g = EdgeDataGraph(data)
            g[NamedEdge(1, 2)] = "E12_updated"
            @test g[NamedEdge(1, 2)] == "E12_updated"
            @test g[NamedEdge(2, 3)] == "E23"
        end

        @testset "undirected edge access" begin
            data = Dictionary([NamedEdge(1, 2)], ["E12"])
            g = EdgeDataGraph(data)
            @test g[NamedEdge(1, 2)] == "E12"
            @test g[NamedEdge(2, 1)] == "E12"
            @test g[1 => 2] == "E12"
            @test g[2 => 1] == "E12"
        end

        @testset "rem_edge!" begin
            data = Dictionary([NamedEdge(1, 2), NamedEdge(2, 3)], ["E12", "E23"])
            g = EdgeDataGraph(data)
            rem_edge!(g, NamedEdge(1, 2))
            @test !has_edge(g, NamedEdge(1, 2))
            @test ne(g) == 1
        end

        @testset "NamedGraphs interface" begin
            g = EdgeDataGraph{E, String, Int}(undef, [1, 2, 3])
            @test Set(collect(vertices(g))) == Set([1, 2, 3])
            @test position_graph(g) isa AbstractGraph
            @test ordered_vertices(g) isa AbstractVector
            @test vertex_positions(g) isa AbstractDictionary
        end

        @testset "Dictionaries interface" begin
            g = EdgeDataGraph{E, String, Int}(undef, [1, 2, 3])
            @test keytype(g) == E
            @test valtype(g) == String
            @test edge_data(g) isa EdgeDataView
        end
    end

    @testset "EdgeDataDiGraph" begin
        E = NamedEdge{Int}

        @testset "undef constructor" begin
            g = EdgeDataDiGraph{E, String, Int}(undef, [1, 2, 3])
            @test g isa EdgeDataDiGraph{E, String, Int}
            @test nv(g) == 3
            @test ne(g) == 0
        end

        @testset "data constructor" begin
            data = Dictionary([NamedEdge(1, 2), NamedEdge(2, 3)], ["E12", "E23"])
            g = EdgeDataDiGraph(data)
            @test g isa EdgeDataDiGraph{E, String, Int}
            @test nv(g) == 3
            @test ne(g) == 2
            @test g[NamedEdge(1, 2)] == "E12"
            @test g[NamedEdge(2, 3)] == "E23"
        end

        @testset "directed graph" begin
            g = EdgeDataDiGraph{E, String, Int}(undef, [1, 2, 3])
            @test is_directed(EdgeDataDiGraph)
            @test is_directed(g)
        end

        @testset "directed edges" begin
            data = Dictionary([NamedEdge(1, 2)], ["E12"])
            g = EdgeDataDiGraph(data)
            @test has_edge(g, NamedEdge(1, 2))
            @test !has_edge(g, NamedEdge(2, 1))
            @test g[NamedEdge(1, 2)] == "E12"
        end

        @testset "DataGraphs interface" begin
            g = EdgeDataDiGraph{E, String, Int}(undef, [1, 2, 3])
            @test edge_data_type(EdgeDataDiGraph{E, String, Int}) == String
            @test edge_data_type(g) == String
            @test keytype(g) == E
            @test valtype(g) == String
            @test edge_data(g) isa EdgeDataView
        end
    end
end

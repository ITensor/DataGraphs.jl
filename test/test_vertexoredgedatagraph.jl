using DataGraphs: DataGraphs, EdgeDataDiGraph, EdgeDataGraph, EdgeDataView,
    VertexDataDiGraph, VertexDataGraph, VertexDataView, edge_data, edge_data_type,
    underlying_graph, vertex_data, vertex_data_type
using Dictionaries:
    AbstractDictionary, Dictionary, IndexError, Indices, isinsertable, issettable, set!
using Graphs: AbstractGraph, AbstractSimpleGraph, add_edge!, add_vertex!, dst, edges,
    edgetype, has_edge, has_vertex, is_directed, ne, nv, rem_edge!, rem_vertex!, src,
    vertices
using NamedGraphs.GraphsExtensions: add_edge, subgraph, vertextype
using NamedGraphs: NamedDiGraph, NamedEdge, NamedGraph, ordered_vertices, position_graph,
    similar_graph, vertex_positions
using Test: @test, @test_throws, @testset

@testset "VertexDataGraph and EdgeDataGraph" begin
    @testset "$GType basics" for GType in (
            VertexDataGraph{String, Int},
            VertexDataDiGraph{String, Int},
        )
        @testset "undef constructor" begin
            g = GType(undef, [1, 2, 3])
            @test g isa GType
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
            g = GType(data)
            @test g isa GType
            @test nv(g) == 3
            @test isassigned(g, 1)
            @test isassigned(g, 2)
            @test isassigned(g, 3)
            @test g[1] == "V1"
            @test g[2] == "V2"
            @test g[3] == "V3"

            data = Dictionary([1.0, 2.0, 3.0], SubString.(["V1", "V2", "V3"]))
            g = GType(data)
            @test g isa GType
        end

        @testset "copy" begin
            data = Dictionary([1, 2, 3], ["V1", "V2", "V3"])
            g = GType(data)
            add_edge!(g, NamedEdge(1, 2))
            g_copy = copy(g)

            @test g_copy == g
            @test g_copy !== g

            # Test we can copy a graph with undefined data.
            g = GType(undef, [1, 2, 3])
            g[1] = "V1"
            add_edge!(g, NamedEdge(2, 3))
            g_copy = copy(g)

            @test has_vertex(g_copy, 1)
            @test has_vertex(g_copy, 2)
            @test has_vertex(g_copy, 3)
            @test has_edge(g_copy, 2 => 3)
            @test isassigned(g_copy, 1)
            @test g_copy[1] == "V1"
            @test !isassigned(g_copy, 2)
            @test !isassigned(g_copy, 3)
        end

        @testset "Graphs.jl interface" begin
            g = GType(undef, [1, 2, 3])
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
            g = GType(undef, [1, 2, 3])
            add_edge!(g, NamedEdge(1, 2))
            rem_vertex!(g, 1)
            @test !has_vertex(g, 1)
            @test nv(g) == 2
            @test ne(g) == 0
        end

        @testset "DataGraphs interface" begin
            g = GType(undef, [1, 2, 3])
            @test vertex_data_type(g) == String
            @test vertex_data_type(GType) == String
            @test !isassigned(g, 1)
            @test !isassigned(g, 2)
            @test !isassigned(g, 3)
            add_edge!(g, NamedEdge(1, 2))
            @test !isassigned(g, 1 => 2)
        end

        @testset "setindex! and getindex" begin
            g = GType(undef, [1, 2, 3])
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
            g = GType(undef, [1, 2, 3])
            @test position_graph(g) isa AbstractSimpleGraph{Int}
            @test ordered_vertices(g) == [1, 2, 3]
            @test keys(vertex_positions(g)) == vertices(g)

            g = add_edge(g, NamedEdge(1, 2))
            g[1] = "1"

            gs = similar_graph(g)
            @test gs isa GType
            @test has_vertex(gs, 1)
            @test has_vertex(gs, 2)
            @test has_vertex(gs, 3)
            @test has_edge(gs, 1 => 2)
            @test !isassigned(gs, 1)

            gs = similar_graph(g, vertices(g))
            @test vertices(gs) == vertices(g)
            @test ne(gs) == 0
            @test !isassigned(gs, 1)

            gs = similar_graph(g, [1, 2, 4])
            @test has_vertex(gs, 1)
            @test has_vertex(gs, 2)
            @test has_vertex(gs, 4)
            @test nv(gs) == 3
            @test ne(gs) == 0
            @test !isassigned(gs, 1)

            gs = similar_graph(g, Char)
            @test vertex_data_type(gs) === Char
            @test nv(gs) == 3
            @test ne(gs) == 1
            gs[1] = 'C'
            @test gs[1] == 'C'

            gs = similar_graph(g, Float64, vertices(g))
            @test ne(gs) == 0

            gs = similar_graph(GType, [1.0, 2.0])
            @test gs isa GType
            @test has_vertex(gs, 1)
            @test has_vertex(gs, 2)
            @test ne(gs) == 0

            g = GType(Dictionary([1, 2, 3], ["V1", "V2", "V3"]))
            add_edge!(g, NamedEdge(1, 2))
            add_edge!(g, NamedEdge(2, 3))
            sg = subgraph(g, [1, 2])
            @test sg isa GType
            @test has_vertex(sg, 1)
            @test has_vertex(sg, 2)
            @test !has_vertex(sg, 3)
            @test has_edge(sg, 1 => 2)
            @test !has_edge(sg, 2 => 3)
            @test sg[1] == "V1"
            @test sg[2] == "V2"
            @test !isassigned(sg, 3)
        end

        @testset "Dictionaries interface" begin
            g = GType(undef, [1, 2, 3])
            @test keytype(g) == Int
            @test valtype(g) == String
            @test keys(g) isa Indices
            @test length(g) == 3
            @test vertex_data(g) isa VertexDataView

            @test issettable(g)
            @test isinsertable(g)

            insert!(g, 4, "V4")
            @test_throws IndexError insert!(g, 4, "V4_again")
            @test has_vertex(g, 4)
            @test isassigned(g, 4)
            @test g[4] == "V4"
            @test nv(g) == 4

            @test_throws IndexError g[5] = "V5"
            @test !has_vertex(g, 5)
            @test !isassigned(g, 5)

            set!(g, 5, "V5")
            @test has_vertex(g, 5)
            @test g[5] == "V5"

            g[5] = "V5_again"
            @test g[5] == "V5_again"
            @test nv(g) == 5
        end

        @testset "show" begin
            g = GType(Dictionary([1, 2, 3], ["V1", "V2", "V3"]))
            io = IOBuffer()
            show(io, g)
            str = String(take!(io))
            @test occursin("$GType", str)
            @test occursin("V1", str)
            @test occursin("V2", str)
            @test occursin("V3", str)
            @test !occursin("edge data", str)
            @test occursin("vertex data", str)
        end
    end

    @testset "$GType basics" for GType in
        (EdgeDataGraph{String, Int}, EdgeDataDiGraph{String, Int})
        @testset "undef constructor" begin
            g = GType(undef, [1, 2, 3])
            @test g isa GType
            @test nv(g) == 3
            @test ne(g) == 0
        end

        @testset "data constructor" begin
            data = Dictionary([NamedEdge(1, 2), NamedEdge(2, 3)], ["E12", "E23"])
            g = GType(data)
            @test g isa GType
            @test nv(g) == 3
            @test ne(g) == 2
            @test isassigned(g, NamedEdge(1, 2))
            @test isassigned(g, NamedEdge(2, 3))
            @test g[NamedEdge(1, 2)] == "E12"
            @test g[NamedEdge(2, 3)] == "E23"

            # With pairs
            data = Dictionary([1.0 => 2.0, 2.0 => 3.0], ["E12", "E23"])
            g = GType(data)
            @test g isa GType
            @test nv(g) == 3
            @test ne(g) == 2
            @test isassigned(g, NamedEdge(1, 2))
            @test isassigned(g, NamedEdge(2, 3))
            @test g[NamedEdge(1, 2)] == "E12"
            @test g[NamedEdge(2, 3)] == "E23"
        end

        @testset "copy" begin
            data = Dictionary([1 => 2, 2 => 3], ["E12", "E23"])
            g = GType(data)
            g_copy = copy(g)

            @test g_copy == g
            @test g_copy !== g

            # Test we can copy a graph with undefined data.
            g = GType(undef, [1, 2, 3])
            insert!(g, 1 => 2, "E12")
            g_copy = copy(g)

            @test has_vertex(g_copy, 1)
            @test has_vertex(g_copy, 2)
            @test has_vertex(g_copy, 3)
            @test has_edge(g_copy, 1 => 2)
            @test isassigned(g_copy, 1 => 2)
            @test g_copy[1 => 2] == "E12"
            @test !isassigned(g_copy, 2 => 3)
        end

        @testset "Graphs.jl interface" begin
            g = GType(undef, [1, 2, 3])
            @test has_vertex(g, 1)
            @test has_vertex(g, 2)
            @test !has_vertex(g, 4)
            @test edgetype(g) == NamedEdge{Int}

            @test_throws ArgumentError add_edge!(g, NamedEdge(1, 2))
            @test_throws ArgumentError add_edge!(g, 2 => 3)

            add_vertex!(g, 4)
            @test has_vertex(g, 4)
            @test nv(g) == 4
        end

        @testset "DataGraphs interface" begin
            g = GType(undef, [1, 2, 3])
            @test edge_data_type(GType) == String
            @test edge_data_type(g) == String
            @test !isassigned(g, 1)
            @test !isassigned(g, NamedEdge(1, 2))
        end

        @testset "setindex! and getindex" begin
            data = Dictionary([NamedEdge(1, 2), NamedEdge(2, 3)], ["E12", "E23"])
            g = GType(data)
            g[NamedEdge(1, 2)] = "E12_updated"
            @test g[NamedEdge(1, 2)] == "E12_updated"
            @test g[NamedEdge(2, 3)] == "E23"
        end

        @testset "rem_edge!" begin
            data = Dictionary([NamedEdge(1, 2), NamedEdge(2, 3)], ["E12", "E23"])
            g = GType(data)
            rem_edge!(g, NamedEdge(1, 2))
            @test !has_edge(g, NamedEdge(1, 2))
            @test ne(g) == 1
        end

        @testset "rem_vertex!" begin
            data = Dictionary([NamedEdge(1, 2), NamedEdge(2, 3)], ["E12", "E23"])
            g = GType(data)
            rem_vertex!(g, 1)
            @test !has_vertex(g, 1)
            @test !has_edge(g, NamedEdge(1, 2))
            @test !isassigned(g, NamedEdge(1, 2))
            @test ne(g) == 1
            @test g[NamedEdge(2, 3)] == "E23"
        end

        @testset "NamedGraphs interface" begin
            g = GType(Dictionary([1 => 2, 2 => 3], ["E12", "E23"]))
            @test issetequal(vertices(g), [1, 2, 3])
            @test position_graph(g) isa AbstractSimpleGraph{Int}
            @test ordered_vertices(g) isa AbstractVector
            @test vertex_positions(g) isa AbstractDictionary

            gs = similar_graph(g)
            @test gs isa GType
            @test has_vertex(gs, 1)
            @test has_vertex(gs, 2)
            @test has_vertex(gs, 3)
            @test has_edge(gs, 1 => 2)
            @test !isassigned(gs, 1 => 2)

            gs = similar_graph(g, vertices(g))
            @test vertices(gs) == vertices(g)
            @test ne(gs) == 0
            @test !isassigned(gs, 1 => 2)

            gs = similar_graph(g, [1, 2, 4])
            @test has_vertex(gs, 1)
            @test has_vertex(gs, 2)
            @test has_vertex(gs, 4)
            @test nv(gs) == 3
            @test ne(gs) == 0
            @test !isassigned(gs, 1 => 2)

            gs = similar_graph(g, Char)
            @test edge_data_type(gs) === Char
            @test nv(gs) == 3
            @test ne(gs) == 2

            gs = similar_graph(g, Float64, vertices(g))
            @test ne(gs) == 0

            gs = similar_graph(GType, [1.0, 2.0])
            @test gs isa GType
            @test has_vertex(gs, 1)
            @test has_vertex(gs, 2)
            @test ne(gs) == 0

            g = GType(Dictionary([1 => 2, 2 => 3], ["E12", "E23"]))
            sg = subgraph(g, [1, 2])
            @test sg isa GType
            @test has_vertex(sg, 1)
            @test has_vertex(sg, 2)
            @test !has_vertex(sg, 3)
            @test has_edge(sg, 1 => 2)
            @test !has_edge(sg, 2 => 3)
            @test sg[1 => 2] == "E12"
        end

        @testset "Dictionaries interface" begin
            g = GType(undef, [1, 2, 3])
            @test keytype(g) == NamedEdge{Int}
            @test valtype(g) == String
            @test edge_data(g) isa EdgeDataView

            @test issettable(g)
            @test isinsertable(g)

            g = GType(undef, [1.0, 2.0, 3.0])
            @test keytype(g) == NamedEdge{Int}

            g = GType(undef, [1, 2, 3, 4])
            # insert!
            insert!(g, 3 => 4, "E34")
            @test has_vertex(g, 4)
            @test has_edge(g, 3 => 4)
            @test isassigned(g, 3 => 4)
            @test g[3 => 4] == "E34"
            @test_throws IndexError insert!(g, 4 => 5, "E45")
            @test_throws IndexError insert!(g, 5 => 6, "E56")
            @test_throws IndexError insert!(g, 3 => 4, "E34_again")
            # setindex!
            g[3 => 4] = "E34_again"
            @test g[3 => 4] == "E34_again"
            @test_throws IndexError g[1 => 2] == ""
            @test_throws IndexError g[2 => 3] == ""
            # set!
            g = GType(undef, [1, 2, 3])
            set!(g, 1 => 2, "E12")
            @test has_edge(g, 1 => 2)
            @test g[1 => 2] == "E12"
            set!(g, 1 => 2, "E12_again")
            @test g[1 => 2] == "E12_again"
            @test_throws IndexError set!(g, 3 => 4, "E34")
            @test_throws IndexError set!(g, 4 => 5, "E45")

            g = EdgeDataGraph{String, Int}(undef, [1, 2, 3])
            @test_throws IndexError edge_data(g)[2 => 3] = "E23"
        end

        @testset "show" begin
            g = GType(Dictionary([1 => 2, 2 => 3], ["E12", "E23"]))
            io = IOBuffer()
            show(io, g)
            str = String(take!(io))
            @test occursin("$GType", str)
            @test occursin("edge data", str)
            @test occursin("E12", str)
            @test occursin("E23", str)
            @test !occursin("vertex data", str)
        end
    end

    @testset "(un)directed graph specific" begin
        @testset "basics" begin
            g = VertexDataGraph(undef, [1, 2, 3])
            @test !is_directed(VertexDataGraph)
            @test !is_directed(g)

            g = VertexDataDiGraph(undef, [1, 2, 3])
            @test is_directed(VertexDataDiGraph)
            @test is_directed(g)

            add_edge!(g, NamedEdge(1, 2))
            @test has_edge(g, NamedEdge(1, 2))
            @test !has_edge(g, NamedEdge(2, 1))
            @test ne(g) == 1

            add_edge!(g, NamedEdge(2, 1))
            @test has_edge(g, NamedEdge(2, 1))
            @test ne(g) == 2

            g = EdgeDataGraph(undef, [1, 2, 3])
            @test !is_directed(VertexDataGraph)
            @test !is_directed(g)

            g = EdgeDataDiGraph(undef, [1, 2, 3])
            @test is_directed(VertexDataDiGraph)
            @test is_directed(g)
        end

        @testset "undirected edge access" begin
            data = Dictionary([NamedEdge(1, 2)], ["E12"])
            g = EdgeDataGraph(data)
            @test g[NamedEdge(1, 2)] == "E12"
            @test g[NamedEdge(2, 1)] == "E12"
            @test g[1 => 2] == "E12"
            @test g[2 => 1] == "E12"
        end

        @testset "directed edge access" begin
            data = Dictionary([NamedEdge(1, 2)], ["E12"])
            g = EdgeDataDiGraph(data)
            @test has_edge(g, NamedEdge(1, 2))
            @test !has_edge(g, NamedEdge(2, 1))
            @test g[NamedEdge(1, 2)] == "E12"
        end
    end
end

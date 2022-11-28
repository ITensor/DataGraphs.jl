using DataGraphs
using Dictionaries
using Graphs
using NamedGraphs
using Suppressor
using Test

@testset "DataGraphs.jl" begin
  @testset "Examples" begin
    examples_path = joinpath(pkgdir(DataGraphs), "examples")
    @testset "Run examples: $filename" for filename in readdir(examples_path)
      if endswith(filename, ".jl")
        @suppress include(joinpath(examples_path, filename))
      end
    end
  end

  @testset "Basics" begin
    g = grid((4,))
    dg = DataGraph{String,Symbol}(g)
    @test !isassigned(dg, Edge(1, 2))
    @test !isassigned(dg, 1 => 2)
    @test !isassigned(dg, Edge(1 => 2))
    @test !isassigned(dg, 1 => 3)
    @test !isassigned(dg, 1)
    @test !isassigned(dg, 2)
    @test !isassigned(dg, 3)
    @test !isassigned(dg, 4)

    @test has_edge(dg, 1, 2)
    @test has_edge(dg, 1 => 2)
    @test !has_edge(dg, 1, 3)
    @test !has_edge(dg, 1 => 3)
    @test has_vertex(dg, 1)
    @test has_vertex(dg, 4)
    @test !has_vertex(dg, 0)
    @test !has_vertex(dg, 5)

    dg[1] = "V1"
    dg[2] = "V2"
    dg[3] = "V3"
    dg[4] = "V4"
    @test isassigned(dg, 1)
    @test dg[1] == "V1"
    @test dg[2] == "V2"
    @test dg[3] == "V3"
    @test dg[4] == "V4"

    dg[1 => 2] = :E12
    dg[2 => 3] = :E23
    dg[Edge(3, 4)] = :E34
    #@test isassigned(dg, (1, 2))
    @test isassigned(dg, Edge(2, 3))
    @test isassigned(dg, 3 => 4)
    @test dg[Edge(1, 2)] == :E12
    @test dg[2 => 3] == :E23
    @test dg[3 => 4] == :E34

    vdata = map(v -> "V$v", Indices(1:4))
    edata = map(e -> "E$(src(e))$(dst(e))", Indices([Edge(1, 2), Edge(2, 3), Edge(3, 4)]))
    dg = DataGraph(g, vdata, edata)

    @test dg[1] == "V1"
    @test dg[2] == "V2"
    @test dg[3] == "V3"
    @test dg[4] == "V4"

    @test dg[1 => 2] == "E12"
    @test dg[2 => 3] == "E23"
    @test dg[3 => 4] == "E34"

    @test DataGraph(g) isa DataGraph{Int,Any,Any,SimpleGraph{Int},Graphs.SimpleGraphs.SimpleEdge{Int}}
    @test DataGraph{String}(g) isa DataGraph{Int,String,Any,SimpleGraph{Int},Graphs.SimpleGraphs.SimpleEdge{Int}}
    @test DataGraph{Any,String}(g) isa DataGraph{Int,Any,String,SimpleGraph{Int},Graphs.SimpleGraphs.SimpleEdge{Int}}

    # TODO: is this needed?
    #@test DataGraph{<:Any,String}(g) isa DataGraph{Any,String}
  end

  @testset "Disjoint unions" begin
    g = DataGraph{String,String}(named_grid((2, 2)))

    for v in vertices(g)
      g[v] = "V$v"
    end
    for e in edges(g)
      g[e] = "E$e"
    end

    gg = g ⊔ g

    @test has_vertex(gg, ((1, 1), 1))
    @test has_vertex(gg, ((1, 1), 2))
    @test has_edge(gg, ((1, 1), 1) => ((1, 2), 1))
    @test has_edge(gg, ((1, 1), 2) => ((1, 2), 2))
    @test nv(gg) == 2nv(g)
    @test ne(gg) == 2ne(g)

    # TODO: Define `vcat`, `hcat`, `hvncat`?
    gg = [g; g]

    @test_broken has_vertex(gg, (1, 1))
    @test_broken has_vertex(gg, (2, 1))
    @test_broken has_vertex(gg, (3, 1))
    @test_broken has_vertex(gg, (4, 1))
    @test_broken has_edge(gg, (1, 1) => (1, 2))
    @test_broken has_edge(gg, (3, 1) => (3, 2))
    @test_broken nv(gg) == 2nv(g)
    @test_broken ne(gg) == 2ne(g)

    gg = [g;; g]

    @test_broken has_vertex(gg, (1, 1))
    @test_broken has_vertex(gg, (1, 2))
    @test_broken has_vertex(gg, (1, 3))
    @test_broken has_vertex(gg, (1, 4))
    @test_broken has_edge(gg, (1, 1) => (1, 2))
    @test_broken has_edge(gg, (1, 3) => (1, 4))
    @test_broken nv(gg) == 2nv(g)
    @test_broken ne(gg) == 2ne(g)
  end

  @testset "union" begin
    g1 = DataGraph(grid((4,)))
    g1[1] = ["A", "B", "C"]
    g1[1 => 2] = ["E", "F"]

    g2 = DataGraph(Graph(5))
    add_edge!(g2, 1 => 5)
    g2[1] = ["C", "D", "E"]

    # Same as:
    # union(g1, g2; merge_data=(x, y) -> y)
    g = union(g1, g2)
    @test nv(g) == 5
    @test ne(g) == 4
    @test has_edge(g, 1 => 2)
    @test has_edge(g, 2 => 3)
    @test has_edge(g, 3 => 4)
    @test has_edge(g, 1 => 5)
    @test g[1] == ["C", "D", "E"]
    @test g[1 => 2] == ["E", "F"]

    g = union(g1, g2; merge_data=union)
    @test nv(g) == 5
    @test ne(g) == 4
    @test has_edge(g, 1 => 2)
    @test has_edge(g, 2 => 3)
    @test has_edge(g, 3 => 4)
    @test has_edge(g, 1 => 5)
    @test g[1] == ["A", "B", "C", "D", "E"]
    @test g[1 => 2] == ["E", "F"]
  end

end

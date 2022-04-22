using DataGraphs
using Dictionaries
using Graphs
using Test

@testset "DataGraphs.jl" begin
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

  vdata = dictionary([1 => "V1", 2 => "V2", 3 => "V3", 4 => "V4"])
  edata = dictionary([Edge(1, 2) => "E12", Edge(2, 3) => "E23", Edge(3, 4) => "E34"])
  dg = DataGraph(g, vdata, edata)

  @test dg[1] == "V1"
  @test dg[2] == "V2"
  @test dg[3] == "V3"
  @test dg[4] == "V4"

  @test dg[1 => 2] == "E12"
  @test dg[2 => 3] == "E23"
  @test dg[3 => 4] == "E34"

  @test DataGraph(g) isa DataGraph{Any,Any}
  @test DataGraph{String}(g) isa DataGraph{String,Any}
  @test DataGraph{Any,String}(g) isa DataGraph{Any,String}

  # TODO: is this needed?
  #@test DataGraph{<:Any,String}(g) isa DataGraph{Any,String}
end

@testset "Disjoint unions" begin
  g = NamedDimDataGraph{String,String}(grid((2, 2)); dims=(2, 2))

  for v in vertices(g)
    g[v] = "V$v"
  end
  for e in edges(g)
    g[e] = "E$e"
  end

  gg = g ⊔ g

  @test has_vertex(gg, 1, 1, 1)
  @test has_vertex(gg, 2, 1, 1)
  @test has_edge(gg, (1, 1, 1) => (1, 1, 2))
  @test has_edge(gg, (2, 1, 1) => (2, 1, 2))
  @test nv(gg) == 2nv(g)
  @test ne(gg) == 2ne(g)

  gg = [g; g]

  @test has_vertex(gg, 1, 1)
  @test has_vertex(gg, 2, 1)
  @test has_vertex(gg, 3, 1)
  @test has_vertex(gg, 4, 1)
  @test has_edge(gg, (1, 1) => (1, 2))
  @test has_edge(gg, (3, 1) => (3, 2))
  @test nv(gg) == 2nv(g)
  @test ne(gg) == 2ne(g)

  gg = [g;; g]

  @test has_vertex(gg, 1, 1)
  @test has_vertex(gg, 1, 2)
  @test has_vertex(gg, 1, 3)
  @test has_vertex(gg, 1, 4)
  @test has_edge(gg, (1, 1) => (1, 2))
  @test has_edge(gg, (1, 3) => (1, 4))
  @test nv(gg) == 2nv(g)
  @test ne(gg) == 2ne(g)
end

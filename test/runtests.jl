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
  @test DataGraph{<:Any,String}(g) isa DataGraph{Any,String}

  vdata = [1 => "V1", 2 => "V2", 3 => "V3", 4 => "V4"]
  edata = [(1, 2) => "E12", (2 => 3) => "E23", Edge(3, 4) => "E34"]
  dg = DataGraph(g, vdata, edata)

  @test dg[1] == "V1"
  @test dg[2] == "V2"
  @test dg[3] == "V3"
  @test dg[4] == "V4"

  @test dg[1 => 2] == "E12"
  @test dg[2 => 3] == "E23"
  @test dg[3 => 4] == "E34"

  vdata = ["V1", "V2", "V3", "V4"]
  edata = [(1, 2) => "E12", (2 => 3) => "E23", Edge(3, 4) => "E34"]
  dg = DataGraph(g, vdata, edata)

  @test dg[1] == "V1"
  @test dg[2] == "V2"
  @test dg[3] == "V3"
  @test dg[4] == "V4"

  @test dg[1 => 2] == "E12"
  @test dg[2 => 3] == "E23"
  @test dg[3 => 4] == "E34"

  vdata = ["V1", "V2", "V3", "V4"]
  edata = ["E12", "E23", "E34"]
  dg = DataGraph(g, vdata, edata)

  @test dg[1] == "V1"
  @test dg[2] == "V2"
  @test dg[3] == "V3"
  @test dg[4] == "V4"

  @test dg[1 => 2] == "E12"
  @test dg[2 => 3] == "E23"
  @test dg[3 => 4] == "E34"

  vdata = ["V1", "V2", "V3", "V4"]
  edata = [Edge(1, 2) => "E12", Edge(2, 3) => "E23"]
  dg = DataGraph(g; vertex_data=vdata, edge_data=edata)

  @test dg[1] == "V1"
  @test dg[2] == "V2"
  @test dg[3] == "V3"
  @test dg[4] == "V4"

  @test dg[1 => 2] == "E12"
  @test dg[2 => 3] == "E23"
  @test !isassigned(dg, 3 => 4)

  vdata = ["V1", "V2", "V3", "V4"]
  dg = DataGraph(g; vertex_data=vdata)

  @test dg[1] == "V1"
  @test dg[2] == "V2"
  @test dg[3] == "V3"
  @test dg[4] == "V4"

  @test !isassigned(dg, 1 => 2)
  @test !isassigned(dg, 2 => 3)
  @test !isassigned(dg, 3 => 4)
end

using DataGraphs: DataGraph
using Graphs: has_edge, has_vertex
using NamedGraphs: NamedEdge
using NamedGraphs.NamedGraphGenerators: named_grid

g = named_grid((4))
dg = DataGraph(g; vertex_data_eltype = String, edge_data_eltype = Symbol)
@show !isassigned(dg, NamedEdge(1, 2))
@show !isassigned(dg, 1 => 2)
@show !isassigned(dg, NamedEdge(1 => 2))
@show !isassigned(dg, 1 => 3)
@show !isassigned(dg, 1)
@show !isassigned(dg, 2)
@show !isassigned(dg, 3)
@show !isassigned(dg, 4)

@show has_edge(dg, 1, 2)
@show has_edge(dg, 1 => 2)
@show !has_edge(dg, 1, 3)
@show !has_edge(dg, 1 => 3)
@show has_vertex(dg, 1)
@show has_vertex(dg, 4)
@show !has_vertex(dg, 0)
@show !has_vertex(dg, 5)

dg[1] = "V1"
dg[2] = "V2"
dg[3] = "V3"
dg[4] = "V4"
@show isassigned(dg, 1)
@show dg[1] == "V1"
@show dg[2] == "V2"
@show dg[3] == "V3"
@show dg[4] == "V4"

dg[1 => 2] = :E12
dg[2 => 3] = :E23
dg[NamedEdge(3, 4)] = :E34
#@show isassigned(dg, (1, 2))
@show isassigned(dg, NamedEdge(2, 3))
@show isassigned(dg, 3 => 4)
@show dg[NamedEdge(1, 2)] == :E12
@show dg[2 => 3] == :E23
@show dg[3 => 4] == :E34

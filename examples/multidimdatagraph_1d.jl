using DataGraphs
using Graphs
using MultiDimDictionaries
using NamedGraphs

g = NamedDimGraph(grid((4,)), ["A", "B", "C", "D"])
dg = NamedDimDataGraph{String,Symbol}(g)

@show has_vertex(dg, "A")
@show has_vertex(dg, "D")
@show !has_vertex(dg, 0)
@show !has_vertex(dg, 5)

@show has_edge(dg, "A", "B")
@show has_edge(dg, "A" => "B")
@show !has_edge(dg, "A", "C")
@show !has_edge(dg, "A" => "C")

@show !isassigned(dg, "A")
@show !isassigned(dg, "B")
@show !isassigned(dg, "C")
@show !isassigned(dg, "D")

@show !isassigned(dg, NamedDimEdge("A", "B"))
@show !isassigned(dg, "A" => "B")
@show !isassigned(dg, NamedDimEdge("A" => "B"))
@show !isassigned(dg, "A" => "C")

dg["A"] = "V1"
dg["B"] = "V2"
dg["C"] = "V3"
dg["D"] = "V4"

# Error: does not have vertex
# dg[1] = "X"

@show isassigned(dg, "A")
@show dg["A"] == "V1"
@show dg["B"] == "V2"
@show dg["C"] == "V3"
@show dg["D"] == "V4"

dg["A" => "B"] = :E12
dg["B" => "C"] = :E23
dg[NamedDimEdge("C", "D")] = :E34
@show isassigned(dg, NamedDimEdge("B", "C"))
@show isassigned(dg, "C" => "D")
@show dg[NamedDimEdge("A", "B")] == :E12
@show dg["B" => "C"] == :E23
@show dg["C" => "D"] == :E34

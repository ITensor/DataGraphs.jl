using DataGraphs
using NamedGraphs
using Dictionaries
using Graphs

g = named_grid((2, 2))
dg = DataGraph{String,String}(g)

dg[1, 1] = "X11"

@show dg[1, 1] == "X11"

dg[(1, 1) => (1, 2)] = "X11↔X12"

@show dg[(1, 1) => (1, 2)] == "X11↔X12"
@show dg[(1, 2) => (1, 1)] == "X11↔X12"

# XXX: Broken
#@show isassigned(dg, (1, 1))
#@show isassigned(dg, 1, 1)

@show isassigned(dg, NamedEdge((1, 1), (1, 2)))
@show !isassigned(dg, NamedEdge((1, 1), (2, 2)))
@show isassigned(dg, (1, 1) => (1, 2))
@show !isassigned(dg, (1, 1) => (2, 2))

## @show has_edge(dg, 1, 2)
## @show has_edge(dg, 1 => 2)
## @show !has_edge(dg, 1, 3)
## @show !has_edge(dg, 1 => 3)
## @show has_vertex(dg, 1)
## @show has_vertex(dg, 4)
## @show !has_vertex(dg, 0)
## @show !has_vertex(dg, 5)
## 
## dg[1] = "V1"
## dg[2] = "V2"
## dg[3] = "V3"
## dg[4] = "V4"
## @show isassigned(dg, 1)
## @show dg[1] == "V1"
## @show dg[2] == "V2"
## @show dg[3] == "V3"
## @show dg[4] == "V4"
## 
## dg[1 => 2] = :E12
## dg[2 => 3] = :E23
## dg[Edge(3, 4)] = :E34
## #@show isassigned(dg, (1, 2))
## @show isassigned(dg, Edge(2, 3))
## @show isassigned(dg, 3 => 4)
## @show dg[Edge(1, 2)] == :E12
## @show dg[2 => 3] == :E23
## @show dg[3 => 4] == :E34

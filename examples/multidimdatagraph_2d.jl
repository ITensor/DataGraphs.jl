using DataGraphs
using NamedGraphs
using Dictionaries
using Graphs

g = named_grid((2, 2))
dg = DataGraph(g, String, String)

dg[1, 1] = "X11"

@show dg[1, 1] == "X11"

dg[(1, 1) => (1, 2)] = "X11↔X12"

@show dg[(1, 1) => (1, 2)] == "X11↔X12"
@show dg[(1, 2) => (1, 1)] == "X11↔X12"

@show isassigned(dg, NamedEdge((1, 1), (1, 2)))
@show !isassigned(dg, NamedEdge((1, 1), (2, 2)))
@show isassigned(dg, (1, 1) => (1, 2))
@show !isassigned(dg, (1, 1) => (2, 2))

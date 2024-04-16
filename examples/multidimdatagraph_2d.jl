using DataGraphs: DataGraph
using NamedGraphs: NamedEdge
using NamedGraphs.NamedGraphGenerators: named_grid

g = named_grid((2, 2))
# TODO: Change to `DataGraph(g; vertex_data_type=String, edge_data_type=String)
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

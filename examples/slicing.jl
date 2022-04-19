using DataGraphs
using NamedGraphs
using Dictionaries
using Graphs

g = NamedDimGraph(grid((2, 2)); dims=(2, 2))
dg = NamedDimDataGraph{String,String}(g)

for v in vertices(dg)
  dg[v] = "V$v"
end

dg_1 = dg[1, :]

@show nv(dg) == 4
# @show nv(dg_1) == 2

using DataGraphs
using NamedGraphs
using Dictionaries
using Graphs

g = NamedDimGraph(grid((2, 2)); dims=(2, 2))
dg = NamedDimDataGraph{String,String}(g)

for v in vertices(dg)
  dg[v] = "V$v"
end
for e in edges(dg)
  dg[e] = "E$e"
end

dg_1c = dg[1, :]
dg_2c = dg[2, :]
dg_c1 = dg[:, 1]
dg_c2 = dg[:, 2]

@show nv(dg) == 4
@show ne(dg) == 4
@show nv(dg_1c) == 2
@show ne(dg_1c) == 1
@show nv(dg_2c) == 2
@show ne(dg_2c) == 1
@show nv(dg_c1) == 2
@show ne(dg_c1) == 1
@show nv(dg_c2) == 2
@show ne(dg_c2) == 1

dg_nn = dg[[(1, 1), (2, 2)]]

@show nv(dg_nn) == 2
@show ne(dg_nn) == 0


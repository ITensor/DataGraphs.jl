using DataGraphs
using NamedGraphs
using Dictionaries
using Graphs

g = named_grid((2, 2))
dg = DataGraph{String,String}(g)

dg[1, 1] = "V11"
dg[1, 2] = "V12"
dg[(1, 1) => (1, 2)] = "E11↔12"

@show dg[1, 1] == "V11"
@show dg[1, 2] == "V12"
@show isnothing(get(dg, (2, 1), nothing))
@show dg[(1, 1) => (1, 2)] == "E11↔12"
@show dg[(1, 2) => (1, 1)] == "E11↔12"
@show isnothing(get(dg, (1, 1) => (2, 1), nothing))

dg_1c = subgraph(v -> v[1] == 1, dg) # dg[1, :]
dg_2c = subgraph(v -> v[1] == 2, dg) # dg[2, :]
dg_c1 = subgraph(v -> v[2] == 1, dg) # dg[:, 1]
dg_c2 = subgraph(v -> v[2] == 2, dg) # dg[:, 2]

@show dg_1c[1, 1] == "V11"
@show dg_1c[1, 2] == "V12"
@show dg_1c[(1, 1) => (1, 2)] == "E11↔12"
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

dg_nn = subgraph(dg, [(1, 1), (2, 2)])

@show nv(dg_nn) == 2
@show ne(dg_nn) == 0

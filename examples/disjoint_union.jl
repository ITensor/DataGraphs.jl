using Graphs
using NamedGraphs
using DataGraphs

g = DataGraph(named_grid((2, 2)), String, String)

for v in vertices(g)
  g[v] = "V$v"
end
for e in edges(g)
  g[e] = "E$e"
end

gg = g ⊔ g

@show has_vertex(gg, ((1, 1), 1))
@show has_vertex(gg, ((1, 1), 2))
@show has_edge(gg, ((1, 1), 1) => ((1, 2), 1))
@show has_edge(gg, ((1, 1), 2) => ((1, 2), 2))
@show nv(gg) == 2nv(g)
@show ne(gg) == 2ne(g)

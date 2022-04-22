using Graphs
using NamedGraphs
using DataGraphs

g = NamedDimDataGraph{String,String}(grid((2, 2)); dims=(2, 2))

for v in vertices(g)
  g[v] = "V$v"
end
for e in edges(g)
  g[e] = "E$e"
end

gg = g ⊔ g

@show has_vertex(gg, 1, 1, 1)
@show has_vertex(gg, 2, 1, 1)
@show has_edge(gg, (1, 1, 1) => (1, 1, 2))
@show has_edge(gg, (2, 1, 1) => (2, 1, 2))
@show nv(gg) == 2nv(g)
@show ne(gg) == 2ne(g)

gg = [g; g]

@show has_vertex(gg, 1, 1)
@show has_vertex(gg, 2, 1)
@show has_vertex(gg, 3, 1)
@show has_vertex(gg, 4, 1)
@show has_edge(gg, (1, 1) => (1, 2))
@show has_edge(gg, (3, 1) => (3, 2))
@show nv(gg) == 2nv(g)
@show ne(gg) == 2ne(g)

gg = [g;; g]

@show has_vertex(gg, 1, 1)
@show has_vertex(gg, 1, 2)
@show has_vertex(gg, 1, 3)
@show has_vertex(gg, 1, 4)
@show has_edge(gg, (1, 1) => (1, 2))
@show has_edge(gg, (1, 3) => (1, 4))
@show nv(gg) == 2nv(g)
@show ne(gg) == 2ne(g)

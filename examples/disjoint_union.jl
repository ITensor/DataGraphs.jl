using Graphs: edges, has_edge, has_vertex, ne, nv, vertices
using NamedGraphs.GraphsExtensions: ⊔
using NamedGraphs.NamedGraphGenerators: named_grid
using DataGraphs: DataGraph

g = DataGraph(g; vertex_data_eltype=String, edge_data_eltype=String)

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

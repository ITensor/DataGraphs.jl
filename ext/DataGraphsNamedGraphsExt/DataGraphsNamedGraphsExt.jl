module DataGraphsNamedGraphsExt
using DataGraphs: DataGraphs, AbstractDataGraph, underlying_graph
using NamedGraphs: NamedGraphs, AbstractNamedGraph

DataGraphs.is_underlying_graph(::Type{<:AbstractNamedGraph}) = true

for f in [:(NamedGraphs.position_graph), :(NamedGraphs.vertex_positions)]
  @eval begin
    function $f(graph::AbstractDataGraph)
      return $f(underlying_graph(graph))
    end
  end
end
end

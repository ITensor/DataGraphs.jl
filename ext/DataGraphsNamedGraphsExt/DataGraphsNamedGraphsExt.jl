module DataGraphsNamedGraphsExt
using DataGraphs: DataGraphs, AbstractDataGraph, underlying_graph
using NamedGraphs: NamedGraphs, AbstractNamedGraph

DataGraphs.is_underlying_graph(::Type{<:AbstractNamedGraph}) = true

for f in [:(NamedGraphs.parent_graph), :(NamedGraphs.parent_vertices_to_vertices)]
  @eval begin
    function $f(graph::AbstractDataGraph, args...; kwargs...)
      return $f(underlying_graph(graph), args...; kwargs...)
    end
  end
end
end

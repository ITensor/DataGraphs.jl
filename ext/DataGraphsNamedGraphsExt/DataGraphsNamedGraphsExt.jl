module DataGraphsNamedGraphsExt
using DataGraphs: DataGraphs, AbstractDataGraph, underlying_graph
using NamedGraphs: NamedGraphs, AbstractNamedGraph

DataGraphs.is_underlying_graph(::Type{<:AbstractNamedGraph}) = true

for f in [:(NamedGraphs.ordinal_graph), :(NamedGraphs.ordinal_vertex_to_vertex)]
  @eval begin
    function $f(graph::AbstractDataGraph, args...; kwargs...)
      return $f(underlying_graph(graph), args...; kwargs...)
    end
  end
end
end

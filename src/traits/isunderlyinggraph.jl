using SimpleTraits: SimpleTraits, @traitdef, @traitimpl, Not

@traitdef IsUnderlyingGraph{X}
#! format: off
@traitimpl IsUnderlyingGraph{X} <- is_underlying_graph(X)
#! format: on

using Graphs: AbstractGraph
is_underlying_graph(::Type{<:AbstractGraph}) = false

using Graphs.SimpleGraphs: AbstractSimpleGraph
is_underlying_graph(::Type{<:AbstractSimpleGraph}) = true

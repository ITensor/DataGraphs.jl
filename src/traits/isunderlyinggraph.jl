@traitdef IsUnderlyingGraph{X}
#! format: off
@traitimpl IsUnderlyingGraph{X} <- is_underlying_graph(X)
#! format: on

is_underlying_graph(::Type{<:AbstractGraph}) = false

is_underlying_graph(::Type{<:AbstractSimpleGraph}) = true
is_underlying_graph(::Type{<:AbstractNamedGraph}) = true

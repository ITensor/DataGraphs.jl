@traitdef IsUnderlyingGraph{X}
@traitimpl IsUnderlyingGraph{AbstractSimpleGraph}
@traitimpl IsUnderlyingGraph{AbstractNamedGraph}
## @traitimpl IsUnderlyingGraph{X} <- is_underlying_graph(X)

## is_underlying_graph(::Type{<:AbstractGraph}) = false
## 
## is_underlying_graph(::Type{<:AbstractSimpleGraph}) = true
## is_underlying_graph(::Type{<:AbstractNamedGraph}) = true

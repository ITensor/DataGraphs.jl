# TODO: Use a function `arrange` like in MetaGraphsNext:
# https://github.com/JuliaGraphs/MetaGraphsNext.jl/blob/1539095ee6088aba0d5b1cb057c339ad92557889/src/metagraph.jl#L75-L80
# to sort the vertices, only directed graphs should store data
# in both edge directions. Also, define `reverse_data_direction` as a function
# stored in directed AbstractDataGraph types (which by default returns nothing,
# indicating not to automatically store data in both directions)
# TODO: Use `Graphs.is_ordered`? https://juliagraphs.org/Graphs.jl/v1.7/core_functions/core/#Graphs.is_ordered-Tuple{AbstractEdge}
function is_arranged(src, dst)
  if !hasmethod(isless, typeof.((src, dst)))
    return is_arranged_by_hash(src, dst)
  end
  return isless(src, dst)
end

function is_arranged_by_hash(src, dst)
  src_hash = hash(src)
  dst_hash = hash(dst)
  if (src_hash == dst_hash) && (src ≠ dst)
    @warn "Hash collision when arranging vertices to extract edge data. Setting or extracting data may be ill-defined."
  end
  return isless(src_hash, dst_hash)
end

# https://github.com/JuliaLang/julia/blob/v1.8.5/base/tuple.jl#L470-L482
is_arranged(::Tuple{}, ::Tuple{}) = false
is_arranged(::Tuple{}, ::Tuple) = true
is_arranged(::Tuple, ::Tuple{}) = false

function is_arranged(t1::Tuple, t2::Tuple)
  a, b = t1[1], t2[1]
  return is_arranged(a, b) || (isequal(a, b) && is_arranged(Base.tail(t1), Base.tail(t2)))
end

@traitfn function is_edge_arranged(graph::AbstractDataGraph::IsDirected, src, dst)
  return true
end

@traitfn function is_edge_arranged(graph::AbstractDataGraph::(!IsDirected), src, dst)
  return is_arranged(src, dst)
end

function is_edge_arranged(graph::AbstractDataGraph, edge::AbstractEdge)
  return is_edge_arranged(graph, src(edge), dst(edge))
end

function arrange(graph::AbstractDataGraph, edge::AbstractEdge)
  return arrange(is_edge_arranged(graph, edge), edge)
end

function arrange(is_arranged::Bool, edge::AbstractEdge)
  return is_arranged ? edge : reverse(edge)
end

# TODO: Store `reverse_data_direction` inside `AbstractDataGraph`
# to control data direction reversal by instance instead of
# just by type.
reverse_data_direction(graph::AbstractDataGraph, data) = data
function reverse_data_direction(is_arranged::Bool, graph::AbstractDataGraph, data)
  return is_arranged ? data : reverse_data_direction(graph, data)
end

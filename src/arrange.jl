# TODO: Use a function `arrange` like in MetaGraphsNext:
# https://github.com/JuliaGraphs/MetaGraphsNext.jl/blob/1539095ee6088aba0d5b1cb057c339ad92557889/src/metagraph.jl#L75-L80
# to sort the vertices, only directed graphs should store data
# in both edge directions. Also, define `reverse_data_direction` as a function
# stored in directed AbstractDataGraph types (which by default returns nothing,
# indicating not to automatically store data in both directions)
# TODO: Use `Graphs.is_ordered`? https://juliagraphs.org/Graphs.jl/v1.7/core_functions/core/#Graphs.is_ordered-Tuple{AbstractEdge}
@traitfn function is_arranged(graph::AbstractDataGraph::IsDirected, src, dst)
  return true
end

@traitfn function is_arranged(graph::AbstractDataGraph::(!IsDirected), src, dst)
  return src < dst
end

function is_arranged(graph::AbstractDataGraph, edge::AbstractEdge)
  return is_arranged(graph, src(edge), dst(edge))
end

function arrange(graph::AbstractDataGraph, edge::AbstractEdge)
  return arrange(is_arranged(graph, edge), edge)
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

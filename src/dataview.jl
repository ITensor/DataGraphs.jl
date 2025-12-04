using Dictionaries: Dictionaries, AbstractDictionary, gettokenvalue

struct VertexDataView{V, VD, G <: AbstractGraph{V}} <: AbstractDictionary{V, VD}
    graph::G
    function VertexDataView(graph)
        V = vertextype(graph)
        VD = vertex_data_eltype(graph)
        G = typeof(graph)
        return new{V, VD, G}(graph)
    end
end

Base.keys(view::VertexDataView) = assigned_vertices(view.graph)

struct EdgeDataView{E, ED, G <: AbstractGraph} <: AbstractDictionary{E, ED}
    graph::G
    function EdgeDataView(graph)
        E = edgetype(graph)
        ED = edge_data_eltype(graph)
        G = typeof(graph)
        return new{E, ED, G}(graph)
    end
end

Base.keys(view::EdgeDataView) = assigned_edges(view.graph)

const VertexOrEdgeDataView{K, V, G} = Union{VertexDataView{K, V, G}, EdgeDataView{K, V, G}}

Base.isassigned(view::VertexOrEdgeDataView{K}, key::K) where {K} = isassigned(view.graph, key)

Base.getindex(view::VertexOrEdgeDataView, key) = view.graph[key]
# Method ambiguity
Base.getindex(view::VertexOrEdgeDataView{K}, key::K) where {K} = view.graph[key]

Dictionaries.istokenizable(::Type{<:VertexOrEdgeDataView}) = true
Dictionaries.istokenassigned(view::VertexOrEdgeDataView, token) = istokenassigned(keys(view), token)
function Dictionaries.gettokenvalue(view::VertexOrEdgeDataView, token)
    return view[gettokenvalue(keys(view), token)]
end

function Base.setindex!(view::VertexOrEdgeDataView{K, V}, data::V, key::K) where {K, V}
    setindex!(view.graph, data, key)
    return view
end

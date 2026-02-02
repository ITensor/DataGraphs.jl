using Dictionaries:
    Dictionaries,
    AbstractDictionary,
    gettokenvalue,
    filterview,
    IndexError,
    Indices,
    getindices
using NamedGraphs: to_graph_index, to_vertices, to_edges

struct VertexDataView{V, VD, G <: AbstractGraph{V}} <: AbstractDictionary{V, VD}
    graph::G
    function VertexDataView(graph)
        V = vertextype(graph)
        VD = vertex_data_type(graph)
        G = typeof(graph)
        return new{V, VD, G}(graph)
    end
end

_keys(view::VertexDataView) = Indices(vertices(view.graph))

struct EdgeDataView{E, ED, G <: AbstractGraph} <: AbstractDictionary{E, ED}
    graph::G
    function EdgeDataView(graph)
        E = edgetype(graph)
        ED = edge_data_type(graph)
        G = typeof(graph)
        return new{E, ED, G}(graph)
    end
end

_keys(view::EdgeDataView) = Indices(edges(view.graph))

const VertexOrEdgeDataView{K, V, G} = Union{VertexDataView{K, V, G}, EdgeDataView{K, V, G}}

function Base.keys(view::VertexOrEdgeDataView)
    return filterview(k -> isassigned(view.graph, k), _keys(view))
end

Base.isassigned(view::VertexOrEdgeDataView{K}, key::K) where {K} = isassigned(view.graph, key)

Base.getindex(view::VertexOrEdgeDataView{K}, key::K) where {K} = _getindex(view, key)
function Base.getindex(view::VertexOrEdgeDataView, key)
    return _getindex(view, to_graph_index(view.graph, key))
end

function _getindex(view::VertexDataView, key)
    if key in keys(view)
        return get_vertex_data(view.graph, key)
    else
        throw(IndexError("VertexDataView does not contain index: $key"))
    end
end
function _getindex(view::EdgeDataView, key)
    if key in keys(view)
        return get_edge_data(view.graph, key)
    else
        throw(IndexError("EdgeDataView does not contain index: $key"))
    end
end

# Support indexing with `Indices`.
Base.getindex(view::VertexOrEdgeDataView, keys::Indices) = getindices(view, keys)

Dictionaries.istokenizable(::Type{<:VertexOrEdgeDataView}) = true
function Dictionaries.istokenassigned(view::VertexOrEdgeDataView, token)
    ind = gettokenvalue(keys(view), token)
    return isassigned(view, ind)
end
function Dictionaries.gettokenvalue(view::VertexOrEdgeDataView, token)
    ind = gettokenvalue(keys(view), token)
    return view[ind]
end

function Base.setindex!(view::VertexOrEdgeDataView{K, V}, data::V, key::K) where {K, V}
    setindex!(view.graph, data, key)
    return view
end
function Dictionaries.settokenvalue!(view::VertexOrEdgeDataView{<:Any, T}, token, value::T) where {T}
    setindex!(view, value, gettokenvalue(keys(view), token))
    return view
end

function Dictionaries.gettoken!(view::VertexOrEdgeDataView{K}, ind::K) where {K}
    # This will intentially error if `ind` is not assigned in `view`.
    return Dictionaries.gettoken(keys(view), ind)
end
function Dictionaries.deletetoken!(view::VertexOrEdgeDataView, token)
    Dictionaries.unset!(view.graph, gettokenvalue(keys(view), token))
    return view
end

function Base.copyto!(dest::VertexOrEdgeDataView, bc::Dictionaries.BroadcastedDictionary)
    for (key, val) in pairs(bc)
        dest[to_graph_index(dest.graph, key)] = val
    end
    return dest
end

function Base.fill!(view::VertexOrEdgeDataView{<:Any, T}, value::T) where {T}
    for key in _keys(view)
        view[key] = value
    end
    return view
end

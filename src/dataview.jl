using Dictionaries: Dictionaries, AbstractDictionary, IndexError, Indices, filterview,
    getindices, gettokenvalue, istokenizable
using NamedGraphs: to_edges, to_graph_index, to_vertices

abstract type AbstractDataView{K, V} <: AbstractDictionary{K, V} end

Dictionaries.issetable(::AbstractDataView) = true
Dictionaries.isinsertable(::AbstractDataView) = false
Dictionaries.istokenizable(view::AbstractDataView) = istokenizable(keys(view))

function Dictionaries.istokenassigned(view::AbstractDataView, token)
    ind = gettokenvalue(keys(view), token)
    return isassigned(view, ind)
end
function Dictionaries.gettokenvalue(view::AbstractDataView, token)
    ind = gettokenvalue(keys(view), token)
    return view[ind]
end

function Dictionaries.settokenvalue!(
        view::AbstractDataView{<:Any, T},
        token,
        value::T
    ) where {T}
    setindex!(view, value, gettokenvalue(keys(view), token))
    return view
end

function Base.fill!(view::AbstractDataView{<:Any, T}, value::T) where {T}
    for key in keys(view)
        view[key] = value
    end
    return view
end

struct VertexDataView{V, VD, G <: AbstractGraph} <: AbstractDataView{V, VD}
    graph::G
    function VertexDataView(graph)
        V = vertextype(graph)
        VD = vertex_data_type(graph)
        G = typeof(graph)
        return new{V, VD, G}(graph)
    end
end

Base.keys(view::VertexDataView) = Indices(vertices(view.graph))

struct EdgeDataView{E, ED, G <: AbstractGraph} <: AbstractDataView{E, ED}
    graph::G
    function EdgeDataView(graph)
        E = edgetype(graph)
        ED = edge_data_type(graph)
        G = typeof(graph)
        return new{E, ED, G}(graph)
    end
end

Base.keys(view::EdgeDataView) = Indices(edges(view.graph))

const VertexOrEdgeDataView{K, V, G} = Union{VertexDataView{K, V, G}, EdgeDataView{K, V, G}}

function Base.isassigned(view::VertexOrEdgeDataView{K}, key::K) where {K}
    return isassigned(view.graph, key)
end
function Base.isassigned(view::EdgeDataView, key::Pair)
    return isassigned(view, to_graph_index(view.graph, key))
end

Base.getindex(view::VertexOrEdgeDataView{K}, key::K) where {K} = _getindex(view, key)
function Base.getindex(view::VertexOrEdgeDataView, key)
    return _getindex(view, to_graph_index(view.graph, key))
end

function _getindex(view::VertexDataView, key)
    key in keys(view) || throw(IndexError("VertexDataView does not contain index: $key"))
    return get_vertex_data(view.graph, key)
end
function _getindex(view::EdgeDataView, key)
    key in keys(view) || throw(IndexError("EdgeDataView does not contain index: $key"))
    return get_edge_data(view.graph, key)
end

# Support indexing with `Indices`.
function Base.setindex!(view::VertexOrEdgeDataView, vals, keys::Indices)
    Dictionaries.setindices!(view, vals, keys)
    return view
end
function Base.setindex!(view::EdgeDataView, vals, keys::Indices{<:Pair})
    setindex!(view, vals, Indices(map(k -> to_graph_index(view.graph, k), collect(keys))))
    return view
end

function Base.setindex!(view::VertexOrEdgeDataView{K, V}, data::V, key::K) where {K, V}
    setindex!(view.graph, data, key)
    return view
end
function Base.setindex!(view::EdgeDataView{<:Any, V}, data::V, key::Pair) where {V}
    setindex!(view, data, to_graph_index(view.graph, key))
    return view
end

function Base.copyto!(dest::VertexOrEdgeDataView, bc::Dictionaries.BroadcastedDictionary)
    for (key, val) in pairs(bc)
        dest[to_graph_index(dest.graph, key)] = val
    end
    return dest
end

function assigned_vertex_data(g::AbstractGraph)
    inds = filterview(k -> isassigned(g, k), keys(vertex_data(g)))
    return view(vertex_data(g), inds)
end

function assigned_edge_data(g::AbstractGraph)
    inds = filterview(k -> isassigned(g, k), keys(edge_data(g)))
    return view(edge_data(g), inds)
end

struct SubDataView{K, V, View} <: AbstractDataView{K, V}
    view::View
    inds::Indices{K}
    function SubDataView(view::VertexOrEdgeDataView, inds::Indices{K}) where {K}
        return new{K, eltype(view), typeof(view)}(view, inds)
    end
end

Base.keys(dvs::SubDataView) = dvs.inds

Base.getindex(view::SubDataView, key) = getindex_dataview(view, key)
Base.getindex(view::SubDataView{K}, key::K) where {K} = getindex_dataview(view, key)
function getindex_dataview(dvs::SubDataView, key)
    isassigned(dvs, key) || throw(IndexError("Dictionary does not contain index: $key"))
    return dvs.view[key]
end

Base.isassigned(view::SubDataView{K}, key::K) where {K} = key in keys(view)
function Base.isassigned(view::SubDataView, key::Pair)
    return isassigned(view, to_graph_index(view.view.graph, key))
end

Base.view(view::VertexOrEdgeDataView, keys::Indices) = SubDataView(view, keys)
function Base.view(view::EdgeDataView, keys::Indices{<:Pair})
    return SubDataView(
        view,
        Indices(map(k -> to_graph_index(view.graph, k), collect(keys)))
    )
end

# For method ambiguity
function Base.setindex!(view::SubDataView{K, V}, data::V, key::K) where {K, V}
    setindex!_dataview(view, data, key)
    return view
end
function Base.setindex!(view::SubDataView{<:Any, V}, data::V, key::Pair) where {V}
    setindex!_dataview(view, data, key)
    return view
end

function setindex!_dataview(view::SubDataView, data, key)
    isassigned(view, key) || throw(IndexError("Dictionary does not contain index: $key"))
    setindex!(view.view, data, key)
    return view
end

function Base.copyto!(dest::SubDataView, bc::Dictionaries.BroadcastedDictionary)
    for (key, val) in pairs(bc)
        dest[key] = val
    end
    return dest
end

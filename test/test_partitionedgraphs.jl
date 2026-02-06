module TestModule

using Graphs: AbstractGraph, vertices, edges, src, dst, has_vertex, has_edge, edgetype
using NamedGraphs: NamedGraphs, NamedGraph, Vertices, Edges
using NamedGraphs.PartitionedGraphs:
    QuotientView,
    QuotientVertex,
    QuotientVertexVertex,
    QuotientVertexVertices,
    QuotientVertices,
    QuotientVerticesVertices,
    QuotientEdge,
    QuotientEdges,
    partitionedgraph,
    QuotientVertexOrEdge,
    PartitionedGraphs,
    partitionedgraph,
    PartitionedGraph,
    departition,
    unpartition,
    quotient_graph,
    quotientvertices,
    quotientedges
using DataGraphs:
    DataGraphs,
    DataGraph,
    AbstractDataGraph,
    vertex_data,
    edge_data,
    assigned_vertex_data,
    assigned_edge_data,
    underlying_graph,
    vertex_data_type,
    edge_data_type
using NamedGraphs.GraphsExtensions: GraphsExtensions, similar_graph, subgraph, vertextype
using NamedGraphs.NamedGraphGenerators: named_path_graph
using Test: @testset, @test, @test_throws
using Dictionaries: Dictionary, IndexError, Indices

struct TestDataGraph{V, VD, ED, DG <: DataGraph{V, VD, ED}, QDG} <: AbstractDataGraph{V, VD, ED}
    graph::DG
    quotientgraph::QDG
end

function TestDataGraph(graph)

    ug = quotient_graph(underlying_graph(graph))

    vertex_data = map(Indices(vertices(ug))) do vertex
        return collect(assigned_vertex_data(graph[QuotientVertex(vertex)]))
    end
    edge_data = map(Indices(edges(ug))) do edge
        return collect(assigned_edge_data(graph[QuotientEdge(edge)]))
    end

    quotientgraph = DataGraphs._DataGraph(
        ug,
        vertex_data,
        edge_data,
    )

    return TestDataGraph(graph, quotientgraph)
end

DataGraphs.underlying_graph(graph::TestDataGraph) = underlying_graph(graph.graph)
PartitionedGraphs.quotient_graph(graph::TestDataGraph) = graph.quotientgraph

function GraphsExtensions.similar_graph(dg::TestDataGraph, graph::AbstractGraph)
    dg = similar_graph(dg.graph, graph)
    return TestDataGraph(dg)
end

for f in [
        :(DataGraphs.is_vertex_assigned),
        :(DataGraphs.is_edge_assigned),
        :(DataGraphs.get_vertex_data),
        :(DataGraphs.get_edge_data),
    ]
    @eval $(f)(graph::TestDataGraph, ind) = $(f)(graph.graph, ind)
end

for f in [
        :(DataGraphs.set_vertex_data!),
        :(DataGraphs.set_edge_data!),
    ]
    @eval $(f)(graph::TestDataGraph, val, ind) = $(f)(graph.graph, val, ind)
end

# Enable separate quotient data

NamedGraphs.to_graph_index(::TestDataGraph, qv::QuotientVertex) = qv
NamedGraphs.to_graph_index(::TestDataGraph, qe::QuotientEdge) = qe

function DataGraphs.get_index_data(graph::TestDataGraph, ind::QuotientVertex)
    return graph.quotientgraph[parent(ind)]
end
function DataGraphs.get_index_data(graph::TestDataGraph, ind::QuotientEdge)
    return graph.quotientgraph[parent(ind)]
end

function DataGraphs.is_graph_index_assigned(graph::TestDataGraph, ind::QuotientVertex)
    return isassigned(graph.quotientgraph, parent(ind))
end
function DataGraphs.is_graph_index_assigned(graph::TestDataGraph, ind::QuotientEdge)
    return isassigned(graph.quotientgraph, parent(ind))
end

function DataGraphs.set_index_data!(graph::TestDataGraph, val, ind::QuotientVertex)
    graph.quotientgraph[parent(ind)] = val
    return graph
end

@testset "DataGraphsPartitionedGraphsExt.jl" begin
    g = named_path_graph(6)
    dg = DataGraph(g; vertex_data_type = String, edge_data_type = Tuple{String, String})

    for vertex in vertices(g)
        dg[vertex] = string(vertex)
    end
    for edge in edges(g)
        dg[edge] = (string(src(edge)), string(dst(edge)))
    end

    pg = partitionedgraph(dg, Dict(:a => [1], :b => [2, 3], :c => [4, 5, 6]))

    tpg = TestDataGraph(pg)

    @testset "Basics" begin

        @test pg isa DataGraph
        @test underlying_graph(pg) isa PartitionedGraph
        @test departition(pg) == dg
        @test unpartition(pg) == dg
        @test quotient_graph(pg) isa DataGraph
        @test has_vertex(quotient_graph(pg), :a)
        @test has_vertex(quotient_graph(pg), :b)
        @test has_vertex(quotient_graph(pg), :c)

        subgraph_type = DataGraph{vertextype(dg), String, Tuple{String, String}, <:NamedGraph}

        @test vertex_data_type(quotient_graph(pg)) <: subgraph_type
        @test edge_data_type(quotient_graph(pg)) <: subgraph_type
        @test vertex_data_type(QuotientView(pg)) <: subgraph_type
        @test edge_data_type(QuotientView(pg)) <: subgraph_type

        @test vertex_data_type(quotient_graph(tpg)) <: Vector{String}
        @test edge_data_type(quotient_graph(tpg)) <: Vector{Tuple{String, String}}
        @test vertex_data_type(QuotientView(tpg)) <: Vector{String}
        @test edge_data_type(QuotientView(tpg)) <: Vector{Tuple{String, String}}
    end

    @testset "Scalar indexing" begin

        @testset "Default data graph indexing" begin
            @test pg[1] == "1"
            @test pg[QuotientVertex(:a)[2]] == "2"
            @test pg[1 => 2] == ("1", "2")
            @test pg[QuotientEdge(:b => :c)[4 => 5]] == ("4", "5")

            qv = QuotientView(pg)
            @test qv[:a] isa DataGraph
            @test underlying_graph(qv[:a]) isa NamedGraph
            @test has_vertex(qv[:a], 1)
            @test has_vertex(qv[:b], 2)
            @test has_vertex(qv[:b], 3)
            @test has_vertex(qv[:c], 4)
            @test has_vertex(qv[:c], 5)
            @test has_vertex(qv[:c], 6)
            @test !has_vertex(qv[:c], 1)
            @test qv[:a][1] == "1"
            @test qv[:b][2] == "2"
            @test qv[:b][3] == "3"
            @test_throws IndexError qv[:c][1]
        end

        @testset "Custom data graph indexing" begin
            @test tpg[1] == "1"
            @test tpg[QuotientVertex(:a)[2]] == "2"
            @test tpg[1 => 2] == ("1", "2")
            @test tpg[QuotientEdge(:b => :c)[4 => 5]] == ("4", "5")

            @test tpg[QuotientVertex(:a)] == ["1"]
            @test tpg[QuotientVertex(:b)] == ["2", "3"]
            @test tpg[QuotientVertex(:c)] == ["4", "5", "6"]

            @test tpg[QuotientEdge(:a => :b)] == [("1", "2")]
            @test tpg[QuotientEdge(:b => :a)] == [("1", "2")]
            @test tpg[QuotientEdge(:b => :c)] == [("3", "4")]
            @test tpg[QuotientEdge(:c => :b)] == [("3", "4")]

            tqv = QuotientView(tpg)

            @test tqv[:a] isa Vector{String}
            @test tqv[:a => :b] isa Vector{Tuple{String, String}}

            @test tqv[:a] == ["1"]
            @test tqv[:b] == ["2", "3"]
            @test tqv[:c] == ["4", "5", "6"]

            @test tqv[:a => :b] == [("1", "2")]
            @test tqv[:b => :a] == [("1", "2")]
            @test tqv[:b => :c] == [("3", "4")]
            @test tqv[:c => :b] == [("3", "4")]


            tqv[:a] = ["one"]
            @test tqv[:a] == ["one"]
            @test tpg[QuotientVertex(:a)] == ["one"]
        end

    end

    @testset "Partition non-preserving indexing" begin
        sg1 = tpg[Vertices([4, 5])]
        sg2 = tpg[QuotientVertex(:c)[Vertices([4, 5])]]
        sg3 = subgraph(tpg, [QuotientVertex(:c)[4], QuotientVertex(:c)[5]])

        sg4 = pg[QuotientVertex(:c)]

        @test sg1 isa TestDataGraph
        @test sg2 isa TestDataGraph
        @test sg3 isa TestDataGraph

        @test sg4 isa DataGraph

        function test_partition_non_preserving_indexing(sg)
            @test !(underlying_graph(sg) isa PartitionedGraph)

            @test has_vertex(sg, 4)
            @test has_vertex(sg, 5)
            @test !has_vertex(sg, 1)
            @test !has_vertex(sg, 2)
            @test !has_vertex(sg, 3)

            @test vertex_data(sg)[4] == "4"
            @test vertex_data(sg)[5] == "5"

            @test has_edge(sg, 4 => 5)
            @test !has_edge(sg, 1 => 2)
            @test !has_edge(sg, 2 => 3)
            @test !has_edge(sg, 3 => 4)

            @test edge_data(sg)[4 => 5] == ("4", "5")

        end

        for (type, sg) in zip(
                ("Vertices", "QuotientVertexVertices", "Vector{QuotientVertexVertex}"),
                (sg1, sg2, sg3)
            )
            @testset "$type" test_partition_non_preserving_indexing(sg)
            @test sg == subgraph(dg, [4, 5])
        end

        @testset "QuotientVertex" begin
            test_partition_non_preserving_indexing(sg4)
            @test has_vertex(sg4, 6)
            @test has_edge(sg4, 5 => 6)
            @test vertex_data(sg4)[5] == "5"
            @test vertex_data(sg4)[6] == "6"
            @test edge_data(sg4)[5 => 6] == ("5", "6")
            @test sg4 == subgraph(dg, [4, 5, 6])
        end
    end

    @testset "Partition-preserving indexing" begin
        sg1 = tpg[QuotientVertices([:a, :b])]
        sg2 = subgraph(tpg, [QuotientVertex(:a), QuotientVertex(:b)])
        sg3 = subgraph(tpg, [QuotientVertex(:a)[Vertices([1])], QuotientVertex(:b)[Vertices([2, 3])]])

        for sg in (sg1, sg2, sg3)
            @test sg isa TestDataGraph
            @test underlying_graph(sg) isa PartitionedGraph

            @test has_vertex(sg, 1)
            @test has_vertex(sg, 2)
            @test has_vertex(sg, 3)
            @test !has_vertex(sg, 4)
            @test !has_vertex(sg, 5)
            @test !has_vertex(sg, 6)

            @test sg[1] == "1"
            @test sg[2] == "2"
            @test sg[3] == "3"
            @test vertex_data(sg)[1] == "1"
            @test vertex_data(sg)[2] == "2"
            @test vertex_data(sg)[3] == "3"
            @test_throws IndexError sg[4]
            @test_throws IndexError vertex_data(sg)[5]

            @test has_edge(sg, 1 => 2)
            @test has_edge(sg, 2 => 3)
            @test !has_edge(sg, 3 => 4)
            @test !has_vertex(sg, 4 => 5)
            @test !has_vertex(sg, 5 => 6)

            @test sg[1 => 2] == ("1", "2")
            @test sg[2 => 3] == ("2", "3")
            @test edge_data(sg)[1 => 2] == ("1", "2")
            @test edge_data(sg)[2 => 3] == ("2", "3")
            @test_throws IndexError sg[3 => 4]
            @test_throws IndexError edge_data(sg)[4 => 5]

            @test has_vertex(QuotientView(sg), :a)
            @test has_vertex(QuotientView(sg), :b)
            @test !has_vertex(QuotientView(sg), :c)

            @test has_edge(QuotientView(sg), :a => :b)
            @test !has_edge(QuotientView(sg), :b => :c)
        end
    end
end

end

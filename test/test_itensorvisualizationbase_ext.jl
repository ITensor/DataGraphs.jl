@eval module $(gensym())
using DataGraphs: AbstractDataGraph, DataGraph
using ITensorVisualizationBase: ITensorVisualizationBase
using NamedGraphs.NamedGraphGenerators: named_grid
using Test: @test, @testset

@testset "DataGraphsITensorVisualizationBaseExt" begin
    g = DataGraph(named_grid((2, 2)))
    @test hasmethod(ITensorVisualizationBase.visualize, Tuple{AbstractDataGraph})
    @test isnothing(ITensorVisualizationBase.visualize(g))
end
end

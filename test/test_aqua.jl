using Aqua: Aqua
using DataGraphs: DataGraphs
using Test: @testset

@testset "Code quality (Aqua.jl)" begin
    Aqua.test_ambiguities(DataGraphs)
    # TODO: Enable the remaining checks with `Aqua.test_all(DataGraphs)`.
end

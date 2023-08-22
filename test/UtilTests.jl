using Test
using GridFunctions

@testset "discretize_test_int" begin
    ui = 0
    uf = 10
    nu = 10
    d = GridFunctions.Utils.discretize(ui, uf, nu)
    @test d == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    @test typeof(d) <: AbstractRange{<:Integer}
end

@testset "discretize_test_float" begin
    ui = 0.0
    uf = 10.0
    nu = 10
    d = GridFunctions.Utils.discretize(ui, uf, nu)
    @test d == [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
    @test typeof(d) <: AbstractRange{<:AbstractFloat}
end

@testset "spacing_tests" begin
    @test GridFunctions.Utils.spacing(0, 10, 10) == 1
    @test GridFunctions.Utils.spacing(0, 1, 10) == 0.1
    @test GridFunctions.Utils.spacing(0, 2, 10) == 0.2
end

@testset "spacing_tests_domain_int" begin
    d = GridFunctions.Domains.Domain([0, 1])
    @test GridFunctions.Utils.spacing(d, 10) == 0.1
    d = GridFunctions.Domains.Domain([0, 10])
    @test GridFunctions.Utils.spacing(d, 10) == 1
    d = GridFunctions.Domains.Domain([0, 2])
    @test GridFunctions.Utils.spacing(d, 10) == 0.2
end

@testset "spacing_tests_domain_float" begin
    d = GridFunctions.Domains.Domain([0.0, 1.0])
    @test GridFunctions.Utils.spacing(d, 10) == 0.1
    d = GridFunctions.Domains.Domain([0.0, 10.0])
    @test GridFunctions.Utils.spacing(d, 10) == 1
    d = GridFunctions.Domains.Domain([0.0, 2.0])
    @test GridFunctions.Utils.spacing(d, 10) == 0.2
end

@testset "spacing_tests_domain_float" begin
    d = [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
    @test GridFunctions.Utils.spacing(d) == 1.0
    d = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    @test GridFunctions.Utils.spacing(d) == 1
    d = [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0] / 10
    @test GridFunctions.Utils.spacing(d) == 0.1
end

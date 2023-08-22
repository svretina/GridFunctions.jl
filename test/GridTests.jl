using Test
using GridFunctions

const ITypes = [Int32, Int64]
const FTypes = [Float32, Float64]

@testset "Grid_tests" begin
    dd = GridFunctions.Domains.Domain([0, 1])
    ncells = 10
    gg = GridFunctions.Grids.Grid(dd, ncells)
    @test gg.domain == dd
    @test length(gg) == ncells + 1
    @test gg.ncells == ncells
    @test gg.npoints == ncells + 1
    @test gg.coords == 0:0.1:1
    @test length(gg.coords) == ncells + 1
    @test gg.spacing == 0.1
end

@testset "Grid_test types" begin
    L = 5
    dd = GridFunctions.Domains.Domain([0, L])
    ncells = 10
    gg = GridFunctions.Grids.Grid(dd, ncells)
    @test typeof(gg.ncells) <: Integer
    @test typeof(gg.npoints) <: Integer
    @test typeof(gg.domain) <: GridFunctions.Domains.Domain{<:Integer}
    @test typeof(gg.spacing) <: AbstractFloat
    @test typeof(gg.coords) <: Vector{<:AbstractFloat}
end

@testset "Grid_test Rational type" begin
    L = Rational(5)
    dd = GridFunctions.Domains.Domain([0, L])
    ncells = 10
    gg = GridFunctions.Grids.Grid(dd, ncells)
    @test typeof(gg.ncells) <: Integer
    @test typeof(gg.npoints) <: Integer
    @test typeof(gg.domain) <: GridFunctions.Domains.Domain{<:Rational}
    @test typeof(gg.spacing) <: Rational
    @test typeof(gg.coords) <: Vector{<:Rational}
end

@testset "Grid_test float type" begin
    L = 5.0
    dd = GridFunctions.Domains.Domain([0, L])
    ncells = 10
    gg = GridFunctions.Grids.Grid(dd, ncells)
    @test typeof(gg.ncells) <: Integer
    @test typeof(gg.npoints) <: Integer
    @test typeof(gg.domain) <: GridFunctions.Domains.Domain{<:AbstractFloat}
    @test typeof(gg.spacing) <: AbstractFloat
    @test typeof(gg.coords) <: Vector{<:AbstractFloat}
end

@testset "Grid_tests_conversion Rational" begin
    for T in ITypes
        L = 5
        dd = GridFunctions.Domains.Domain([0, L])
        ncells = 10
        g = GridFunctions.Grids.Grid(dd, ncells)
        gg = convert(Rational{T}, g)
        @test typeof(gg.ncells) <: Integer
        @test typeof(gg.npoints) <: Integer
        @test typeof(gg.domain) <: GridFunctions.Domains.Domain{<:Rational}
        @test typeof(gg.spacing) <: Rational
        @test typeof(gg.coords) <: Vector{<:Rational}
    end
end

@testset "Grid_tests_conversion Floats" begin
    for T in FTypes
        L = 5
        dd = GridFunctions.Domains.Domain([0, L])
        ncells = 10
        g = GridFunctions.Grids.Grid(dd, ncells)
        gg = convert(T, g)
        @test typeof(gg.ncells) <: Integer
        @test typeof(gg.npoints) <: Integer
        @test typeof(gg.domain) <: GridFunctions.Domains.Domain{<:AbstractFloat}
        @test typeof(gg.spacing) <: AbstractFloat
        @test typeof(gg.coords) <: Vector{<:AbstractFloat}
    end
end
@testset "Grid_tests_conversion2Int" begin
    L = 5
    dd = GridFunctions.Domains.Domain([0, L])
    ncells = 5
    g = GridFunctions.Grids.Grid(dd, ncells)
    gg = convert(Int64, g)
    @test typeof(gg.ncells) <: Integer
    @test typeof(gg.npoints) <: Integer
    @test typeof(gg.domain) <: GridFunctions.Domains.Domain{<:Integer}
    @test typeof(gg.spacing) <: AbstractFloat
    @test typeof(gg.coords) <: Vector{<:AbstractFloat}
end

@testset "Grid_test_CFL" begin
    L = 5
    dd = GridFunctions.Domains.Domain([0, L])
    ncells = 5
    g = GridFunctions.Grids.Grid(dd, ncells)
    cfl = 0.5
    time_domain = GridFunctions.Domains.Domain([0, 2])
    time_grid = GridFunctions.Grids.TimeGrid_from_cfl(g, time_domain, cfl)
    @test time_grid.spacing / g.spacing == cfl
end

using Test
using GridFunctions
using StaticArrays

const ITypes = [Int32, Int64]
const FTypes = [Float32, Float64]

@testset "helper funcs" begin
    # x = 0:0.5:5
    # @test spacing(x) == 0.5 # spacing not defined for range anymore
    @test coords(0, 1, 10) == 0:0.1:1
    @test coords([0, 1], 10) == 0:0.1:1
end

@testset "UniformGrid1D_tests Floats" begin
    for T in FTypes
        d = T[0, 1]
        ncells = 10
        g = GridFunctions.Grids.UniformGrid1D(d, ncells)
        @test g.domain == d
        @test g.ncells == ncells
        @test coords(g) == collect(T, 0:0.1:1)
        @test length(g) == ncells + 1
        @test spacing(g) == T(0.1)
        @test typeof(g.domain) <: SVector{2,T}
        @test typeof(coords(g)) <: AbstractVector{<:AbstractFloat}
    end
end

@testset "UniformGrid1D_tests Ints" begin
    for T in ITypes
        d = T[0, 1]
        ncells = 10
        g = GridFunctions.Grids.UniformGrid1D(d, ncells)
        @test g.domain == d
        @test g.ncells == ncells
        @test coords(g) == 0:0.1:1
        @test length(g) == ncells + 1
        @test spacing(g) == 0.1
        @test typeof(g.domain) <: SVector{2,T}
        @test typeof(coords(g)) <: AbstractVector{<:AbstractFloat}
    end
end

@testset "UniformGrid 1d fallback" begin
    g = GridFunctions.Grids.UniformGrid([0, 1], 10)
    @test typeof(g) <: GridFunctions.Grids.UniformGrid1D
end

@testset "UniformGrid Floats" begin
    for T in FTypes
        d = [T[0, 1], T[2, 3]]
        ncells = [10, 10]
        g = GridFunctions.Grids.UniformGrid(d, ncells)
        gcoords = [T[0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0],
            T[2.0, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 3.0]]
        # Convert lazy tuple coords to vector of vectors for comparison
        c_vecs = [collect(c) for c in coords(g)]
        @test c_vecs == gcoords
    end
end
@testset "UniformGrid Ints" begin
    for T in ITypes
        d = [T[0, 1], T[2, 3]]
        ncells = [10, 10]
        g = GridFunctions.Grids.UniformGrid(d, ncells)
        gcoords = [[0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0],
            [2.0, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 3.0]]
        c_vecs = [collect(c) for c in coords(g)]
        @test c_vecs == gcoords
    end
end

@testset "UniformGrid 1st Constructor" begin
    for T in [ITypes..., FTypes...]
        d = [T[0, 1], T[2, 3]]
        ncells = 10
        g = GridFunctions.Grids.UniformGrid(d, ncells)
        @test g.ncells == @SVector [10, 10]
    end
end

@testset "UniformGrid 2nd Constructor" begin
    for i in 1:3
        for T in [ITypes..., FTypes...]
            d = T[0, 1]
            ncells = 10
            g = GridFunctions.Grids.UniformGrid(d, ncells, i)
            @test g.ncells == 10 * @SVector ones(Int64, i)
        end
    end
end

using Test
using GridFunctions

const ITypes = [Int32, Int64]
const FTypes = [Float32, Float64]
const RTypes = [ITypes..., FTypes...]

const d = [0, 1]
const n = 10

@testset "Default constructor" begin
    for T in RTypes
        g = UniformGrid(T.(d), n)
        vals = coords(g)
        f = GridFunction(g, vals)
        @test f.grid == g
        @test f.values == vals
    end
end

@testset "Default constructor" begin
    g = UniformGrid(d, n)
    vals = 1:1:100
    @test_throws DimensionMismatch GridFunction(g, vals)
end

@testset "Coords" begin
    g = UniformGrid(d, n)
    f = GridFunction(g, coords(g))
    @test coords(g) == coords(g)
end

@testset "Analytic Function provided" begin
    g = UniformGrid(d, n, 3)
    f = GridFunction(g, x -> sin(x[1]) * cos(x[2]) * sin(x[3]))
    x = coords(g)
    vals = similar(f.values)
    for indx in CartesianIndices(x)
        i, j, k = indx
        vals[i, j, k] = sin(x[i, j, k]) * cos(x[i, j, k]) * sin(x[i, j, k])
    end
    @test f.values == vals
end

@testset "1d grid special case" begin
    g = UniformGrid(d, n)
    f = GridFunction(g, sin)
    @test f.values == sin(g)
end

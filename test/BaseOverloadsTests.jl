using Test
using GridFunctions

const ITypes = [Int32, Int64]
const FTypes = [Float32, Float64]
const RTypes = [ITypes..., FTypes...]

const d = [0, 1]
const n = 10

@testset "Identity UniformGrid1d" begin
    for T in RTypes
        g1 = GridFunctions.Grids.UniformGrid1d(T.(d), n)
        g2 = GridFunctions.Grids.UniformGrid1d(T.(d), n)
        @test g1 == g2
    end
end

@testset "Base.length(UniformGrid1d)" begin
    for T in RTypes
        g = GridFunctions.Grids.UniformGrid1d(T.(d), n)
        @test length(g) == g.ncells + 1
        @test length(g) == length(coords(g))
    end
end

@testset "Base.size(UniformGrid1d)" begin
    for T in RTypes
        g = GridFunctions.Grids.UniformGrid1d(T.(d), n)
        @test size(g) == (g.ncells + 1,)
        @test size(g) == size(coords(g))
    end
end

@testset "Base.eltype(UniformGrid1d)" begin
    for T in RTypes
        g = GridFunctions.Grids.UniformGrid1d(T.(d), n)
        @test eltype(g) == T
    end
end

@testset "Base.eltype(UniformGrid)" begin
    for T in RTypes
        d = T[0, 1]
        n = 10
        g = GridFunctions.Grids.UniformGrid(d, n, 2)
        @test eltype(g) == T
    end
end

@testset "Base.ndims(UniformGrid1d)" begin
    for T in RTypes
        g = GridFunctions.Grids.UniformGrid1d(T.(d), n)
        @test ndims(g) == 1
    end
end

@testset "Base.ndims(UniformGrid)" begin
    for i in 1:3
        for T in RTypes
            g = GridFunctions.Grids.UniformGrid(T.(d), n, i)
            @test ndims(g) == i
        end
    end
end

@testset "Base.size(UniformGrid)" begin
    for i in 1:3
        for T in RTypes
            g = GridFunctions.Grids.UniformGrid(T.(d), n, i)
            @test size(g) == Tuple(g.ncells .+ 1)
        end
    end
end

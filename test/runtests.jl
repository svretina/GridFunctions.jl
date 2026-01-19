using SafeTestsets

@safetestset "Grids.jl" begin
    include("GridTests.jl")
end

@safetestset "BaseOverloads.jl" begin
    include("BaseOverloadsTests.jl")
end

@safetestset "Functions.jl" begin
    include("FunctionTests.jl")
end
@safetestset "BaseTests.jl" begin
    include("BaseTests.jl")
end

@safetestset "CoverageTests.jl" begin
    include("CoverageTests.jl")
end

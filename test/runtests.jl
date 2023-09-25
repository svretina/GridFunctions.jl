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

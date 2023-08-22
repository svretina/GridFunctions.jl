using SafeTestsets

@safetestset "Domains.jl" begin
    include("DomainTests.jl")
end

@safetestset "Utils.jl" begin
    include("UtilTests.jl")
end

@safetestset "Grids.jl" begin
    include("GridTests.jl")
end

@safetestset "Functions.jl" begin
    include("FunctionTests.jl")
end

@safetestset "Base.jl" begin
    include("BaseTests.jl")
end

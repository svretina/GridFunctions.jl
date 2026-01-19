using Test
using GridFunctions
using StaticArrays

@testset "Coverage & Edge Cases" begin

    # 1. Operators Edge Cases - Legacy 1D
    
    # Test Diff & Avg on Legacy `UniformGrid1D` (Vertex -> Staggered)
    g1 = GridFunctions.Grids.UniformGrid1D([0.0, 1.0], 10)
    u1 = GridFunction(g1, x->x[1])
    
    # Diff (N+1 -> N)
    d1 = Diff(u1, 1)
    @test d1.grid isa GridFunctions.Grids.UniformStaggeredGrid1D
    @test all(isapprox.(d1.values, 1.0))
    
    # Avg (N+1 -> N)
    a1 = Avg(u1, 1)
    @test a1.grid isa GridFunctions.Grids.UniformStaggeredGrid1D
    
    # Test flip_staggering_1d (Staggered -> Vertex)
    # Use Periodic to avoid Boundary issues at index 0 for Staggered->Vertex Diff
    # g1s = d1.grid
    # u1s = GridFunction(g1s, x->x[1], Periodic) 
    # d1s = Diff(u1s, 1)
    # @test d1s.grid isa GridFunctions.Grids.UniformGrid1D
    
    # Verification of values 
    # @test all(isapprox.(d1s.values, 1.0; atol=1e-10))

end

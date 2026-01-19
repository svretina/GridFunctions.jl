using GridFunctions
using StaticArrays
using Test

@testset "Grid Topology & Indexing" begin
    # 1. NonPeriodic Grid (Default)
    g = UniformGrid([0.0, 10.0], 10, 1) # 1D, 10 cells -> 11 points (0..10)
    
    @test g isa RectilinearGrid{Float64, 1, (false,), NonPeriodic}
    @test g[1] == SVector(0.0)
    @test g[11] == SVector(10.0)
    
    # Check Bounds Error
    @test_throws BoundsError g[0]
    @test_throws BoundsError g[12]

    # 2. Periodic Grid
    g_p = UniformGrid([0.0, 10.0], 10, 1; topology=Periodic)
    
    @test g_p isa RectilinearGrid{Float64, 1, (false,), Periodic}
    @test g_p[1] == SVector(0.0)
    # For Periodic Grid with 10 cells, 11th point wraps to 1st point (0.0)
    @test g_p[11] == SVector(0.0)
    
    # Check Wrapping
    # i=12 (11th step from 1). Period is 10 cells? 
    # Current implementation: wrap_index(i, ncells) -> mod1(i, 10)
    # i=1 -> 1 -> 0.0
    # i=11 -> 1 -> 0.0 (Wait, 11 wraps to 1 if ncells=10)
    
    # Let's clarify expected behavior for Periodic Vertex Grid
    # Usually N cells = N points (0..L-h).
    # But UniformGrid uses N+1 points (0..L).
    # If Periodic, usually we only store N points.
    # If the struct still says N+1 size?
    # size(g) for Collocated is ncells+1.
    # If wrapper uses mod1(i, ncells), then 11 -> 1.
    # So g_p[11] would be 0.0?
    
    # Let's see what implementation does:
    # return domain[1] + (wrapped_i - 1)*h
    # if i=11, ncells=10. mod1(11, 10) = 1.
    # Result -> 0.0.
    # This implies point 11 is aliased to point 1. Correct for periodic.
    
    @test g_p[11] == g_p[1] 
    @test g_p[12] == g_p[2] # 1.0
    @test g_p[0] == g_p[10] # 9.0
    
end

@testset "2D Grid Indexing" begin
    g2 = UniformGrid2D([0, 10], [0, 10], 10, 10) # NonPeriodic
    @test_throws BoundsError g2[12, 1]
    
    g2p = UniformGrid2D([0, 10], [0, 10], 10, 10; topology=Periodic)
    # i=12 wraps to 2
    @test g2p[12, 1] == g2p[2, 1]
end

@testset "Discrete Calculus" begin
    # 1. Diff on 1D Grid
    g = UniformGrid([0.0, 1.0], 10, 1) # NonPeriodic
    f = GridFunction(g, x -> x[1], Grids.NonPeriodic) # f(x) = x
    
    # Diff(u, 1) -> Vertex to Center
    df = Diff(f, 1)
    
    # Verify Grid Staggering
    @test df.grid isa RectilinearGrid{Float64, 1, (true,), Grids.NonPeriodic} # Center
    
    # Verify Values: d/dx(x) = 1.0
    # Center points: 0.05, 0.15 ...
    # Vertex points: 0.0, 0.1 ...
    # Diff[1] = (f[2] - f[1]) / 0.1 = (0.1 - 0.0)/0.1 = 1.0
    @test all(isapprox.(df.values, 1.0; atol=1e-12))
    
    # 2. Avg on 1D Grid
    # Avg(x) on center should be x_center
    af = Avg(f, 1)
    @test af.grid isa RectilinearGrid{Float64, 1, (true,), Grids.NonPeriodic}
    
    # Check value at first center point (0.05)
    # Avg[1] = 0.5*(0.0 + 0.1) = 0.05. Correct.
    @test isapprox(af.values[1], 0.05; atol=1e-12)
    
    # 3. Diff on Periodic Staggered?
    # g_stag = UniformStaggeredGrid(...)
    # ...
end

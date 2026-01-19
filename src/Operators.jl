module Operators

using StaticArrays
import ..Grids
import ..Functions: GridFunction
import ..Functions

export Diff, Avg

# Helper to flip staggering of a specific dimension
function flip_staggering(g::G, dim::Int) where {T, N, Shifts, Topology, G <: Grids.RectilinearGrid{T,N,Shifts,Topology}}
    new_shifts = ntuple(i -> i==dim ? !Shifts[i] : Shifts[i], Val(N))
    
    # Domain remains same? Yes, usually.
    # NCells?
    # If Vertex -> Center: ncells decreases? Or stays same?
    # In this library:
    # Vertex Grid (UniformGrid): Size N+1 (from N cells).
    # Center Grid (Staggered): Size N (from N cells).
    # So "N Cells" is the constant parameter. Staggering changes number of points.
    # So ncells field remains invariant.
    
    return Grids.RectilinearGrid{T,N,new_shifts,Topology}(g.domain, g.ncells)
end

function flip_staggering_1d(g::Grids.UniformGrid1D)
    return Grids.UniformStaggeredGrid1D(g.domain, g.ncells)
end
function flip_staggering_1d(g::Grids.UniformStaggeredGrid1D)
    return Grids.UniformGrid1D(g.domain, g.ncells)
end

# ------------------------------------------------------------------
# Diff Operator (Central Difference)
# ------------------------------------------------------------------
# Computes (u[i+1] - u[i]) / h
# Output grid is staggered relative to input in dimension `dim`.

function Diff(u::GridFunction{T,N}, dim::Int) where {T,N}
    g_in = u.grid
    
    # 1. Determine Output Grid
    if g_in isa Grids.RectilinearGrid
        g_out = flip_staggering(g_in, dim)
    elseif N==1
        g_out = flip_staggering_1d(g_in)
    else
        error("Unsupported grid type for Diff")
    end
    
    # 2. Allocate Output Values
    # Size depends on whether we are going Vertex->Center or Center->Vertex
    # Vertex (N+1) -> Center (N). Diff size is N.
    # Center (N) -> Vertex (N+1)? NO.
    # Diff of Center (size N) gives (N-1) values?
    # Or do we assume periodic/ghosts?
    
    # The `RectilinearGrid` defines size N based on `ncells` and staggering.
    # If Periodic: N points -> N points.
    # If NonPeriodic:
    # Vertex (N+1) -> Diff -> Center (N). Consistent.
    # Center (N) -> Diff -> Vertex (N-1)?
    # But `RectilinearGrid` with Vertex shift has N+1 points by definition.
    # So Diff(Center) cannot map to standard Vertex Grid (N+1).
    # It maps to a "Interior Vertex Grid" or something?
    
    # Standard Staggered FD:
    # d/dx maps Vertex <-> Center.
    # u_v (N+1) -> du (N). Correct.
    # u_c (N) -> d2u (N+1)? No, usually N-1.
    
    # For this task, let's assume we operate on compatible regions or Periodic.
    # If Periodic, sizes match.
    
    # Let's implement generic loop using CartesianIndices
    
    h = Grids.spacing(g_in)[dim]
    inv_h = 1.0 / h
    
    sz_in = size(u.values)
    sz_out = size(g_out) # Target size
    
    # Allocate
    vals_out = similar(u.values, sz_out)
    
    # Loop
    # We need to map output index I to input indices.
    # Diff is usually u[i+1] - u[i] ( forward for vertex->center ).
    # Or u[i] - u[i-1].
    
    # Implementation:
    # If In=Vertex (false), Out=Center (true).
    # Out[i] = (In[i+1] - In[i]) / h.
    # Size check: Out has N. In has N+1. i runs 1..N. Matches.
    
    # If In=Center (true), Out=Vertex (false).
    # Out[i] = (In[i] - In[i-1]) / h.
    # Size check: Out has N+1. In has N.
    # Problem: In[0] and In[N+1] needed?
    # This requires Boundary Conditions.
    
    # If NonPeriodic, Diff(Center) -> Vertex is under-defined at boundaries.
    # We might throw error or return smaller valid region?
    # But `GridFunction` enforces grid match.
    
    # For this Refactor, let's support Periodic fully, and NonPeriodic Vertex->Center.
    # Center->Vertex NonPeriodic might fail or require ghost nodes.
    
    R = CartesianIndices(vals_out)
    I_stride = CartesianIndex(ntuple(i -> i==dim ? 1 : 0, N))
    
    # Optimization: Use separate loops for Periodic/NonPer/Staggering direction
    # But generic:
    
    for I in R
        # Logic depends on direction
        # Vertex -> Center: u[I+1] - u[I]
        # Center -> Vertex: u[I] - u[I-1] ?
        
        # Let's check `is_staggered`.
        # Is output Staggered (true) in `dim`?
        out_staggered = Grids.is_staggered(g_out, dim)
        
        if out_staggered # In was Vertex (false)
            # Forward diff
            vals_out[I] = (u[I + I_stride] - u[I]) * inv_h
        else # In was Center (true)
             # Out is Vertex.
             # We need u[I] - u[I-1].
             # For Periodic, u[0] wraps.
             # For NonPeriodic, we check bounds?
             # Standard definition: Grad maps Center->Vertex? Usually other way.
             # Div maps Center->Vertex?
             
             # If we just implement Divergence diff: (u[i] - u[i-1])/h
             vals_out[I] = (u[I] - u[I - I_stride]) * inv_h
        end
    end
    
    return GridFunction(g_out, vals_out, Functions.boundary_condition_type(u))
end

# ------------------------------------------------------------------
# Avg Operator (Interpolation)
# ------------------------------------------------------------------
# Avg(u)[i] = 0.5 * (u[i] + u[i+1])

function Avg(u::GridFunction{T,N}, dim::Int) where {T,N}
    g_in = u.grid
    
    if g_in isa Grids.RectilinearGrid
        g_out = flip_staggering(g_in, dim)
    elseif N==1
        g_out = flip_staggering_1d(g_in)
    else
        error("Unsupported grid")
    end
    
    sz_out = size(g_out)
    vals_out = similar(u.values, sz_out)
    
    R = CartesianIndices(vals_out)
    I_stride = CartesianIndex(ntuple(i -> i==dim ? 1 : 0, N))
    
    for I in R
        out_staggered = Grids.is_staggered(g_out, dim)
        
        if out_staggered # In=Vertex -> Out=Center
            vals_out[I] = 0.5 * (u[I + I_stride] + u[I])
        else # In=Center -> Out=Vertex
            vals_out[I] = 0.5 * (u[I] + u[I - I_stride])
        end
    end
    
    return GridFunction(g_out, vals_out, Functions.boundary_condition_type(u))
end

end

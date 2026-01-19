module Grids

using StaticArrays
import Base.length
import Base.size

export RectilinearGrid, UniformGrid, UniformGrid1D, spacing, coords, UniformStaggeredGrid1D
export UniformGrid2D, UniformGrid3D, UniformStaggeredGrid, UniformStaggeredGrid2D, UniformStaggeredGrid3D
export Periodic, NonPeriodic

abstract type AbstractBoundaryCondition end
struct Periodic <: AbstractBoundaryCondition end
struct NonPeriodic <: AbstractBoundaryCondition end

abstract type AbstractGrid{T,N} <: AbstractArray{T,N} end

# ------------------------------------------------------------------
# Struct Definitions
# ------------------------------------------------------------------

struct UniformGrid1D{T<:Real} <: AbstractGrid{T,1}
    domain::SVector{2,T}
    ncells::Int64
end

struct UniformStaggeredGrid1D{T<:Real} <: AbstractGrid{T,1}
    domain::SVector{2,T}
    ncells::Int64
end

# Generalized Rectilinear Grid
# Shifts: Tuple{Bool, Bool...} where false=Vertex, true=Center
struct RectilinearGrid{T<:Real, N, Shifts, Topology<:AbstractBoundaryCondition} <: AbstractGrid{T,N}
    domain::SVector{N, SVector{2, T}}
    ncells::SVector{N, Int}
end

# Accessors
is_staggered(::RectilinearGrid{T,N,Shifts}, dim::Int) where {T,N,Shifts} = Shifts[dim]


# Aliases for 2D/3D convenience
# We can't verify generic UniformGrid{T,N} easily as an alias, so we rely on RectilinearGrid.
const UniformGrid2D{T,C} = RectilinearGrid{T, 2, (false, false), C}
const UniformGrid3D{T,C} = RectilinearGrid{T, 3, (false, false, false), C}
const UniformStaggeredGrid2D{T,C} = RectilinearGrid{T, 2, (true, true), C}
const UniformStaggeredGrid3D{T,C} = RectilinearGrid{T, 3, (true, true, true), C}

# ------------------------------------------------------------------
# Spacing & Coordinates
# ------------------------------------------------------------------

@inline function spacing(xi::T, xn::T, ncells::Integer) where {T<:Real}
    return (xn - xi) / ncells
end

# 1D overload (Restricted to Legacy Structs)
@inline function spacing(g::Union{UniformGrid1D{T}, UniformStaggeredGrid1D{T}}) where {T<:Real}
    return spacing(g.domain[1], g.domain[2], g.ncells)
end

# N-D overload
@inline function spacing(g::AbstractGrid{T,N}) where {T,N}
    return SVector{N,T}(spacing(g.domain[i][1], g.domain[i][2], g.ncells[i]) for i in 1:N)
end

@inline function range_coords(ui::Real, uf::Real, ncells::Int, staggered::Bool)
    h = spacing(ui, uf, ncells)
    if staggered
        return range(start=ui+0.5h, stop=uf-0.5h, length=ncells)
    else
        return range(start=ui, stop=uf, length=ncells+1)
    end
end

# 1. coords(g) -> Tuple of ranges
@inline function coords(g::UniformGrid1D{T}) where {T}
    return collect(range_coords(g.domain[1], g.domain[2], g.ncells, false))
end

@inline function coords(g::RectilinearGrid{T,N,Shifts}) where {T,N,Shifts}
    return ntuple(i -> range_coords(g.domain[i][1], g.domain[i][2], g.ncells[i], Shifts[i]), Val(N))
end

# ------------------------------------------------------------------
# On-Demand Indexing
# ------------------------------------------------------------------

@inline function wrap_index(g, i::Int, dim::Int)
    return mod1(i, g.ncells[dim])
end

# 1D Legacy
@inline function Base.getindex(g::UniformGrid1D, i::Int)
    @boundscheck (1 <= i <= g.ncells + 1) || throw(BoundsError(g, i))
    h = spacing(g)
    return g.domain[1] + (i-1)*h
end

@inline function Base.getindex(g::UniformStaggeredGrid1D, i::Int)
    @boundscheck (1 <= i <= g.ncells) || throw(BoundsError(g, i))
    h = spacing(g)
    return g.domain[1] + (i-0.5)*h
end

# Rectilinear N-D Indexing
@inline function Base.getindex(g::RectilinearGrid{T,N,Shifts,Topology}, I::Vararg{Int, N}) where {T,N,Shifts,Topology}
    h = spacing(g)
    
    # Check Bounds or Wrap
    # If NonPeriodic, we check bound.
    # Bound depends on Shift. If Staggered (true), size is N. If Vertex (false), size is N+1.
    if Topology <: NonPeriodic
         @boundscheck begin
            valid = true
            for d in 1:N
                 sz = Shifts[d] ? g.ncells[d] : g.ncells[d] + 1
                 if !(1 <= I[d] <= sz)
                     valid = false
                     break
                 end
            end
            valid || throw(BoundsError(g, I))
         end
    end

    # Calculate Coordinate
    coords = ntuple(Val(N)) do d
        idx = (Topology <: Periodic) ? wrap_index(g, I[d], d) : I[d]
        offset = Shifts[d] ? 0.5 : 1.0 # 1.0 means (i-1), 0.5 means (i-0.5)
        # Formula: Start + (i - offset? No.)
        # Vertex (offset 1.0 in logic?): i=1 -> Start. So (i-1).
        # Center (offset 0.5): i=1 -> Start + 0.5h. So (i-0.5).
        # Let's use (i - shift_val) where shift_val = Shifts[d] ? 0.5 : 1.0
        # Wait:
        # Vertex: i=1 -> x0. x = x0 + (i-1)h.
        # Center: i=1 -> x0 + 0.5h. x = x0 + (i-0.5)h.
        # So subtraction constant is: Shifts[d] ? 0.5 : 1.0. Correct.
        k = Shifts[d] ? 0.5 : 1.0
        g.domain[d][1] + (idx - k) * h[d]
    end
    return SVector{N, T}(coords)
end

# ------------------------------------------------------------------
# Helpers & Constructors
# ------------------------------------------------------------------

# Legacy Helpers
@inline Base.similar(g::UniformGrid1D) = UniformGrid1D(similar(g.domain), g.ncells)
UniformGrid1D(d::AbstractVector{T}, ncells::Int) where {T<:Real} = UniformGrid1D(SVector{2,T}(d), ncells)
UniformStaggeredGrid1D(d::AbstractVector{T}, ncells::Int) where {T<:Real} = UniformStaggeredGrid1D(SVector{2,T}(d), ncells)

function coords(ui::Real, uf::Real, ncells::Real)
    h = spacing(ui, uf, ncells)
    return collect(ui:h:uf)
end

function coords(domain::AbstractVector{T}, ncells::Int) where {T<:Real}
    length(domain) === 2 || throw(DimensionMismatch("domain needs to be Vector of length 2"))
    return coords(domain[1], domain[2], ncells)
end

coords(g::UniformGrid1D{<:Real}) = coords(g.domain, g.ncells)

# Size overload for Rectilinear
function Base.size(g::RectilinearGrid{T,N,Shifts}) where {T,N,Shifts}
    return ntuple(i -> Shifts[i] ? g.ncells[i] : g.ncells[i] + 1, Val(N))
end

# ------------------------------------------------------------------
# Constructors (UniformGrid -> RectilinearGrid)
# ------------------------------------------------------------------

# Compatibility Constructors
# 0. 1D Fallback to Legacy Structs (Vertex)
function UniformGrid(domain::AbstractVector{T}, ncells::Int) where {T<:Real}
    return UniformGrid1D(domain, ncells)
end

# 1D Fallback to Legacy Structs (Staggered)
function UniformStaggeredGrid(domain::AbstractVector{T}, ncells::Int) where {T<:Real}
    return UniformStaggeredGrid1D(domain, ncells)
end

# 1.5 Generic N-dim from domains + scalar ncells
function UniformGrid(domains::AbstractVector{<:AbstractVector{T}}, ncells::Int; topology::Type{C}=NonPeriodic) where {T<:Real, C<:AbstractBoundaryCondition}
    N = length(domains)
    return UniformGrid(domains, repeat([ncells], N); topology=topology)
end

# Generic N-dim constructor
function UniformGrid(domains::AbstractVector{<:AbstractVector{T}}, ncells::AbstractVector{<:Int}; topology::Type{C}=NonPeriodic) where {T<:Real, C<:AbstractBoundaryCondition}
    N = length(domains)
    s_domains = SVector{N, SVector{2, T}}(SVector{2, T}(d) for d in domains)
    s_ncells = SVector{N, Int}(ncells)
    shifts = ntuple(i -> false, N) # All Vertex
    return RectilinearGrid{T,N,shifts,C}(s_domains, s_ncells)
end

# Symmetric
function UniformGrid(domain::AbstractVector{T}, ncells::Int, ValN::Val{N}; topology::Type{C}=NonPeriodic) where {T<:Real, N, C<:AbstractBoundaryCondition}
    return UniformGrid(repeat([domain], N), repeat([ncells], N); topology=topology)
end
UniformGrid(domain::AbstractVector{T}, ncells::Int, N::Int; topology::Type{C}=NonPeriodic) where {T, C<:AbstractBoundaryCondition} = UniformGrid(domain, ncells, Val(N); topology=topology)

# 2D/3D Explicit (Returning typed Alias if possible or generic Rectilinear)
function UniformGrid2D(dom_x, dom_y, nx::Int, ny::Int; topology::Type{C}=NonPeriodic) where {C<:AbstractBoundaryCondition}
    return UniformGrid([dom_x, dom_y], [nx, ny]; topology=topology)
end

function UniformGrid3D(dom_x, dom_y, dom_z, nx::Int, ny::Int, nz::Int; topology::Type{C}=NonPeriodic) where {C<:AbstractBoundaryCondition}
    return UniformGrid([dom_x, dom_y, dom_z], [nx, ny, nz]; topology=topology)
end

# ------------------------------------------------------------------
# Constructors (UniformStaggeredGrid -> RectilinearGrid)
# ------------------------------------------------------------------

function UniformStaggeredGrid(domains::AbstractVector{<:AbstractVector{T}}, ncells::AbstractVector{<:Int}; topology::Type{C}=NonPeriodic) where {T<:Real, C<:AbstractBoundaryCondition}
    N = length(domains)
    s_domains = SVector{N, SVector{2, T}}(SVector{2, T}(d) for d in domains)
    s_ncells = SVector{N, Int}(ncells)
    shifts = ntuple(i -> true, N) # All Center
    return RectilinearGrid{T,N,shifts,C}(s_domains, s_ncells)
end

UniformStaggeredGrid(domain::AbstractVector{T}, ncells::Int, N::Int; topology::Type{C}=NonPeriodic) where {T, C<:AbstractBoundaryCondition} = 
    UniformStaggeredGrid(repeat([domain], N), repeat([ncells], N); topology=topology)

function UniformStaggeredGrid2D(dom_x, dom_y, nx::Int, ny::Int; topology::Type{C}=NonPeriodic) where {C<:AbstractBoundaryCondition}
    return UniformStaggeredGrid([dom_x, dom_y], [nx, ny]; topology=topology)
end

function UniformStaggeredGrid3D(dom_x, dom_y, dom_z, nx::Int, ny::Int, nz::Int; topology::Type{C}=NonPeriodic) where {C<:AbstractBoundaryCondition}
    return UniformStaggeredGrid([dom_x, dom_y, dom_z], [nx, ny, nz]; topology=topology)
end

end # end of module

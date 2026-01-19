module Functions

using StaticArrays
import ..Grids
import Base.Iterators

export GridFunction, coords

abstract type AbstractFunction{T,N} <: AbstractArray{T,N} end

### Needs promotion rules!

struct GridFunction{T,N,G<:Grids.AbstractGrid{<:Any,N},V<:AbstractArray{T,N},C<:Grids.AbstractBoundaryCondition} <: AbstractFunction{T,N}
    grid::G
    values::V
    function GridFunction(grid::G, values::V, ::Type{C}) where {T,N,G<:Grids.AbstractGrid{<:Any,N},V<:AbstractArray{T,N},C<:Grids.AbstractBoundaryCondition}
        size(grid) == size(values) ||
            throw(DimensionMismatch("grid and values need to have same length! You provided grid length of $(size(grid))
                                                                                   and value length of $(size(values))"))
        return new{T,N,G,V,C}(grid, values)
    end
end

function GridFunction(x::X, y::Y,
                      periodic::Bool=false) where {TG, T, N, X<:Grids.AbstractGrid{TG,N},
                                                   Y<:AbstractArray{T,N}}
    C = periodic ? Grids.Periodic : Grids.NonPeriodic
    return GridFunction(x, y, C)
end

function Grids.coords(f::GridFunction)
    return Grids.coords(f.grid)
end


# 1D specialization (Legacy, uses broadcast on vector)
function GridFunction(x::Grids.UniformGrid1D{TG}, f::Function,
                       periodic::Bool=false) where {TG<:Real}
    return GridFunction(x, f.(Grids.coords(x)), periodic)
end

function GridFunction(x::Grids.UniformGrid1D{TG}, f::Function,
                      ::Type{C}) where {TG<:Real, C<:Grids.AbstractBoundaryCondition}
    return GridFunction(x, f.(Grids.coords(x)), C)
end

# Generic N-D specialization (Uses Iterators.product on lazy tuple ranges)
function GridFunction(x::Grids.AbstractGrid{TG,N}, f::Function,
                      ::Type{C}=Grids.NonPeriodic) where {TG,N, C<:Grids.AbstractBoundaryCondition}
    # coords(x) returns (rx, ry, rz...) -> Product yields (xi, yi, zi) tuples
    # We broadcast f over this lazy product
    # Use SVector(p) to infer type from coordinates, ignoring Grid's type TG definition if coords differ
    vals = map(p -> f(SVector{N}(p)), Iterators.product(Grids.coords(x)...))
    return GridFunction(x, vals, C)
end

function boundary_condition_type(::GridFunction{T,N,G,V,C}) where {T,N,G,V,C}
    return C
end

function GridFunction(x::Grids.AbstractGrid{TG,N}, f::Function, periodic::Bool) where {TG,N}
    C = periodic ? Grids.Periodic : Grids.NonPeriodic
    return GridFunction(x, f, C)
end

end #end of module

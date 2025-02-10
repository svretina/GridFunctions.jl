module Functions

import ..Grids
import Base.Iterators

export GridFunction, coords

abstract type AbstractFunction{T,N} <: AbstractArray{T,N} end

### Needs promotion rules!

struct GridFunction{T,N,G<:Grids.AbstractGrid{T,N},V<:AbstractArray{T,N}} <: AbstractFunction{T,N}
    grid::G
    values::V
    periodic::Bool
    function GridFunction{T,N}(grid::G, values::V,
                               periodic::Bool) where {G<:Grids.AbstractGrid{T,N},V<:AbstractArray{T,N}} where {T,N}
        Tuple(grid.ncells) .+ 1 == size(values) ||
            throw(DimensionMismatch("grid and values need to have same length! You provided grid length of $(size(grid))
                                                                                   and value length of $(size(values))"))
        return new{T,N,G,V}(grid, values, periodic)
    end
end

# function GridFunction(x::Grids.AbstractGrid{T}, y::AbstractArray{S}, periodic::Bool=false) where {T<:Real,S<:Real}
#     C = promote_type(T, S)
#     return GridFunction(convert.(C, x), C.(y), periodic)
# end

function GridFunction(x::X, y::Y,
                      periodic::Bool=false) where {X<:Grids.AbstractGrid{T,N},
                                                   Y<:AbstractArray{T,N}} where {T,N}
    return GridFunction{T,N}(x, y, periodic)
end

function Grids.coords(f::GridFunction)
    return Grids.coords(f.grid)
end

# function GridFunction(g::Grids.UniformGrid{T,N}, f::Function, periodic::Bool=false) where {T<:Real,N<:Int}
#     @show "CC"
#     npoints = Tuple(g.ncells) .+ 1
#     values = Array{Float64}(undef, npoints)
#     grid_coords = collect(Base.Iterators.product((Grids.coords(g))...))
#     for indices in CartesianIndices(npoints)
#         values[indices] = f([grid_coords[indices]...])
#     end
#     return GridFunction(g, values, periodic)
# end

function GridFunction(x::Grids.UniformGrid1D{T}, f::Function,
                      periodic::Bool=false) where {T<:Real}
    return GridFunction(x, f.(Grids.coords(x)), periodic)
end

end #end of module

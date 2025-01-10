module Functions

import ..Grids
import Base.Iterators

export GridFunction, coords

# abstract type AbstractFunction{T} <: AbstractArray end

### Needs promotion rules!

struct GridFunction{T<:Real} <: AbstractArray{T,1}
    grid::Grids.AbstractGrid{T}
    values::AbstractArray{T}
    periodic::Bool
    function GridFunction{T}(x::Grids.AbstractGrid{T}, y::AbstractArray{T}, periodic) where {T<:Real}
        Tuple(x.ncells) .+ 1 == size(y) || throw(DimensionMismatch("grid and values need to have same dimensions!"))
        return new(x, y, periodic)
    end
end

# function GridFunction(x::Grids.AbstractGrid{T}, y::AbstractArray{S}, periodic::Bool=false) where {T<:Real,S<:Real}
#     C = promote_type(T, S)
#     return GridFunction(convert.(C, x), C.(y), periodic)
# end


function GridFunction(x::Grids.AbstractGrid{T}, y::AbstractArray{T}, periodic::Bool=false) where {T<:Real}
    return GridFunction{T}(x, y, periodic)
end

function Grids.coords(f::GridFunction)
    return Grids.coords(f.grid)
end

function GridFunction(g::Grids.UniformGrid{T}, f::Function, periodic::Bool=false) where {T<:Real}
    npoints = Tuple(g.ncells) .+ 1
    values = Array{Float64}(undef, npoints)
    grid_coords = collect(Base.Iterators.product((Grids.coords(g))...))
    for indices in CartesianIndices(npoints)
        values[indices] = f([grid_coords[indices]...])
    end
    return GridFunction(g, values, periodic)
end

function GridFunction(x::Grids.UniformGrid1d{T}, f::Function, periodic::Bool=false) where {T<:Real}
    return GridFunction(x, f.(Grids.coords(x)), periodic)
end



end #end of module

module Functions

import ..Grids
import Base.Iterators

export GridFunction, coords

abstract type AbstractFunction{T} end

struct GridFunction{T<:Real,S<:Real} <: AbstractFunction{T}
    grid::Grids.AbstractGrid{T}
    values::AbstractArray{S}
    function GridFunction{T,S}(x::Grids.AbstractGrid{T}, y::AbstractArray{S}) where {T<:Real,S<:Real}
        Tuple(x.ncells) .+ 1 == size(y) || throw(DimensionMismatch("grid and values need to have same dimensions!"))
        return new(x, y)
    end
end

function GridFunction(x::Grids.AbstractGrid{T}, y::AbstractArray{S}) where {T<:Real,S<:Real}
    return GridFunction{T,S}(x, y)
end

function Grids.coords(f::GridFunction)
    return Grids.coords(f.grid)
end

function GridFunction(g::Grids.UniformGrid{T}, f::Function) where {T<:Real}
    npoints = Tuple(g.ncells) .+ 1
    values = Array{Float64}(undef, npoints)
    grid_coords = collect(Base.Iterators.product((Grids.coords(g))...))
    for indices in CartesianIndices(npoints)
        values[indices] = f([grid_coords[indices]...])
    end
    return GridFunction(g, values)
end


function GridFunction(x::Grids.UniformGrid1d{T}, f::Function) where {T<:Real}
    return GridFunction(x, f.(Grids.coords(x)))
end


end #end of module

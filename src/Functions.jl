module Functions

import ..Grids
import Base.Iterators
import Base.getindex, Base.setindex!

export GridFunction, coords

abstract type AbstractFunction{T} end

struct GridFunction{T<:Real,S<:Real} <: AbstractFunction{T}
    grid::Grids.AbstractGrid{T}
    values::AbstractArray{S}
    periodic::Bool
    function GridFunction{T,S}(x::Grids.AbstractGrid{T}, y::AbstractArray{S}, periodic) where {T<:Real,S<:Real}
        Tuple(x.ncells) .+ 1 == size(y) || throw(DimensionMismatch("grid and values need to have same dimensions!"))
        return new(x, y, periodic)
    end
end

function GridFunction(x::Grids.AbstractGrid{T}, y::AbstractArray{S}, periodic::Bool=false) where {T<:Real,S<:Real}
    return GridFunction{T,S}(x, y, periodic)
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

function Base.getindex(f::GridFunction, i)
    if f.periodic
        N = f.grid.ncells + 1
        if all(i .> N)
            return f.values[i.-N]
        elseif all(i .< 1)
            return f.values[i.+N]
        elseif all(1 .< i .< N)
            return f.values[i]
        else
            throw("Range can only be positive numbers! You provided $i")
        end
    else
        return f.values[i]
    end
end

function Base.setindex!(f::GridFunction, x, i::Int)
    if f.periodic
        N = f.grid.ncells + 1
        if i > N
            f.values[i-N] = x
        elseif i < 1
            f.values[i+N] = x
        else
            f.values[i] = x
        end
    else
        f.values[i] = x
    end
    return nothing
end

function Base.setindex!(f::GridFunction, x, i::AbstractVector)
    for ii in i
        Base.setindex!(f, x, ii)
    end
end

function Base.lastindex(f::GridFunction)
    return f.grid.ncells + 1
end


end #end of module

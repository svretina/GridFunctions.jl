module Functions

import ..Grids

struct GridFunction{T<:Real}
    x::Vector{T}
    y::Vector{T}
    function GridFunction{T}(x::Vector{T}, y::Vector{T}) where {T<:Real}
        length(x) == length(y) ||
            throw(DimensionMismatch("GridFunction: x has different length from y."))
        return new(x, y)
    end
end

function GridFunction(x::Vector{T}, y::Vector{T}) where {T<:Real}
    GridFunction{T}(x, y)
end

function GridFunction(x::Vector{<:Real}, y::Vector{<:Real})::GridFunction
    return GridFunction(promote(x, y)...)
end

function GridFunction(x::Vector{<:Real}, f::Function)::GridFunction
    return GridFunction(x, f.(x))
end

# if grid is of subtype Rational and a function like sin is passed, then there is a problem
function GridFunction(g::Grids.Grid, f::Function)::GridFunction
    return GridFunction(g.coords, f.(g.coords))
end

function GridFunction(g::Grids.Grid, y::Vector{<:Real})::GridFunction
    return GridFunction(g.coords, y)
end

struct GridFunction3D{T<:Real,S<:Real}
    x::Vector{T}
    y::Vector{T}
    z::Vector{T}
    values::Array{S,3}
end

function GridFunction3D(grid::Grids.Grid3D{T}, vals::Array{S,3}) where {T<:Real,S<:Real}
    dim = size(vals)
    length(grid.x) == dim[1] && length(grid.y) == dim[2] && length(grid.z) == dim[3] ||
        throw(DimensionMismatch("GridFunction: x,y,z have different lengths from values."))
    return GridFunction3D(grid.x, grid.y, grid.z, vals)
end


end

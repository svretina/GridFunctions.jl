module Functions

import ..Grids

abstract type AbstractGridFunction end

# should it hold more information such as the domain and maybe spacing etc?
struct GridFunction{T<:Real} <: AbstractGridFunction
    x::AbstractVector{T}
    y::AbstractVector{T}
    """
    GridFunction{T}(x::AbstractVector{T}, y::AbstractVector{T}) where {T<:Real}

    Basic constructor for GridFunction type. Called
    """
    function GridFunction{T}(x::AbstractVector{T}, y::AbstractVector{T}) where {T<:Real}
        length(x) == length(y) ||
            throw(DimensionMismatch("GridFunction: length(x)=$(length(x)) != length(y)=$(length(y))."))
        return new(x, y)
    end
end

"""
    GridFunction(x::AbstractVector{T}, y::AbstractVector{T}) where {T<:Real}

GridFunction constructor called with 2 vectors of common type to initialize `x`,`y`.
# Examples
```julia-repl
julia> gf = GridFunctions.Functions.GridFunction([0,1,2,3],[0,1,2,3])
GridFunctions.Functions.GridFunction{Int64}([0, 1, 2, 3], [0, 1, 2, 3])
```
"""
function GridFunction(x::AbstractVector{T}, y::AbstractVector{T}) where {T<:Real}
    GridFunction{T}(x, y)
end

"""
    GridFunction(x::AbstractVector{<:Real}, y::AbstractVector{<:Real})::GridFunction

GridFunction constructor called with 2 vectors of different type to initialize `x`,`y`.
# Examples
```julia-repl
julia> gf = GridFunctions.Functions.GridFunction([0,1,2,3],Float64[0,1,2,3])
GridFunctions.Functions.GridFunction{Float64}([0.0, 1.0, 2.0, 3.0], [0.0, 1.0, 2.0, 3.0])
```
"""
function GridFunction(x::AbstractVector{<:Real}, y::AbstractVector{<:Real})::GridFunction
    return GridFunction(promote(x, y)...)
end

"""
    GridFunction(x::AbstractVector{<:Real}, f::Function)::GridFunction

GridFunction constructor called with a vector for x-values and an expression (f) to be evaluated as f.(x)
If the grid values (`x`) are of type <:Rational and the function result is not of type Rational, such as a
sin(x) function, then the results are promoted to a common type (most likely Float64).
# Examples
```julia-repl
julia> gf = GridFunctions.Functions.GridFunction([0,1,2,3],exp)
GridFunctions.Functions.GridFunction{Float64}([0.0, 1.0, 2.0, 3.0], [1.0, 2.718281828459045, 7.38905609893065, 20.085536923187668])

julia> gf = GridFunctions.Functions.GridFunction([0,1,2,3],sin)
GridFunctions.Functions.GridFunction{Float64}([0.0, 1.0, 2.0, 3.0], [0.0, 0.8414709848078965, 0.9092974268256817, 0.1411200080598672])

julia> gf = GridFunctions.Functions.GridFunction(Rational{Int64}[0,1,2,3],sin)
GridFunctions.Functions.GridFunction{Float64}([0.0, 1.0, 2.0, 3.0], [0.0, 0.8414709848078965, 0.9092974268256817, 0.1411200080598672])
```
"""
function GridFunction(x::AbstractVector{<:Real}, f::Function)::GridFunction
    return GridFunction(x, f.(x))
end

# if grid is of subtype Rational and a function like sin is passed, then there is a problem
"""
    GridFunction(g::Grids.Grid, f::Function)::GridFunction

GridFunction constructor called with a Grids.Grid type and an expression
# Examples
```julia-repl
julia> d = GridFunctions.Domains.Domain([0,1])
GridFunctions.Domains.Domain{Int64}([0, 1], 0, 1)

julia> g = GridFunctions.Grids.Grid(d, 10)
GridFunctions.Grids.Grid{Int64, Float64, Int64}(GridFunctions.Domains.Domain{Int64}([0, 1], 0, 1), 10, 11, [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0], 0.1)

julia> gf = GridFunctions.Functions.GridFunction(g, sin)
GridFunctions.Functions.GridFunction{Float64}([0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0], [0.0, 0.09983341664682815, 0.19866933079506122, 0.29552020666133955, 0.3894183423086505, 0.479425538604203, 0.5646424733950354, 0.644217687237691, 0.7173560908995228, 0.7833269096274834, 0.8414709848078965])
```
"""
function GridFunction(g::Grids.Grid, f::Function)::GridFunction
    return GridFunction(g.coords, f.(g.coords))
end

"""
    GridFunction(g::Grids.Grid, y::AbstractVector{<:Real})::GridFunction

GridFunction constructor called with a Grids.Grid type and a vector of function values (`y`)
# Examples
```julia-repl
julia> gf = GridFunctions.Functions.GridFunction(g, 1.:11.)
GridFunctions.Functions.GridFunction{Float64}([0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0], 1.0:1.0:11.0)
```
"""
function GridFunction(g::Grids.Grid, y::AbstractVector{<:Real})::GridFunction
    return GridFunction(g.coords, y)
end

"""
    Base.show(io::IO, gf::GridFunction)

Overloads Base.show to custom print GridFunctions
"""
function Base.show(io::IO, gf::GridFunction)
    dump(gf)
end

"""
    Base.show(io::IO, ::MIME"text/plain", gf::GridFunction)

Overloads Base.show to custom print GridFunctions in REPL
"""
function Base.show(::IO, ::MIME"text/plain", gf::GridFunction)
    dump(gf)
end
## 3D functions
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

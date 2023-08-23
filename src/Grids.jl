module Grids

import ..Domains
import ..Utils

abstract type AbstractGrid end

# rename to UniformGrid
struct Grid{T<:Real,S<:Real,R<:Integer} <: AbstractGrid
    domain::Domains.Domain{T}
    ncells::R
    npoints::R
    coords::AbstractVector{S}
    spacing::S
end


"""
    Grid(domain::Domains.Domain{<:Real},
    ncells::Integer)::Grid{<:Real,<:Real,<:Integer}

Grid constructor called with a Domain type and number of cells (`ncells`)
# Examples
```julia-repl
julia> d = GridFunctions.Domains.Domain([0,1])
GridFunctions.Domains.Domain{Int64}([0, 1], 0, 1)
julia> g = GridFunctions.Grids.Grid(d, 10)
GridFunctions.Grids.Grid{Int64, Float64, Int64}(GridFunctions.Domains.Domain{Int64}([0, 1], 0, 1), 10, 11, [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0], 0.1)
```
"""
function Grid(domain::Domains.Domain{<:Real},
    ncells::Integer)::Grid{<:Real,<:Real,<:Integer}
    npoints = ncells + 1
    coords = Utils.discretize(domain.dmin, domain.dmax, ncells)
    spacing = Utils.spacing(domain, ncells)
    ## is collect a good choice?
    return Grid(domain, ncells, npoints, collect(typeof(spacing), coords), spacing)
end

"""
    Base.show(io::IO, g::Grid)

Overloads Base.show to custom print Grid
"""
function Base.show(io::IO, g::Grid)
    dump(g)
end

"""
    Base.show(io::IO, ::MIME"text/plain", g::Grid)

Overloads Base.show to custom print Grid in REPL
"""
function Base.show(io::IO, ::MIME"text/plain", g::Grid{T,S,R}) where {T,S,R}
    println(Grid{T,S,R})
    println("domain = SVector{$T}$(g.domain.domain)")
    # println("ncells = $(g.ncells)")
    println("npoints = $(g.npoints)")
    println("spacing = $(g.spacing)")
    println("coords = $(g.coords)")
end

# function Grid(domain::Domains.Domain{<:Rational}, ncells::Integer)::Grid
#     npoints = ncells + 1
#     coords = Utils.discretize(domain.dmin, domain.dmax, ncells)
#     spacing = Utils.spacing(domain, ncells)
#     return Grid(domain, ncells, npoints, collect(coords), spacing)
# end

import Base
function Base.convert(::Type{T}, g::Grid)::Grid{<:Real,<:Real,<:Integer} where {T<:Real}
    Grid(convert(T, g.domain), g.ncells)
end

## currently only a cube domain is supported
## dx=dy=dz
## nx=ny=nz
## Make it use Grid for xyz
struct Grid3D{T<:Real,S<:Real,R<:Integer}
    domain::Domains.Domain3D{T}
    ncells::R
    npoints::R
    x::AbstractVector{S}
    y::AbstractVector{S}
    z::AbstractVector{S}
    spacing::S
end

function Grid3D(domain::Domains.Domain3D{<:Real},
    ncells::Integer)::Grid3D{<:Real,<:Real,<:Integer}
    npoints = ncells + 1
    coords = Utils.discretize(domain.xmin, domain.xmax, ncells)
    spacing = Utils.spacing(domain.domain[1], ncells)
    T = typeof(spacing)
    x = collect(T, coords)
    y = collect(T, coords)
    z = collect(T, coords)
    return Grid3D(domain, ncells, npoints, x, y, z, spacing)
end

function TimeGrid_from_cfl(spatial_grid::Grid, time_domain::Domains.Domain, cfl::Real)::Grid
    ncells_t = ceil(Int64,
        (1 / cfl) *
        ((time_domain.domain[2] - time_domain.domain[1]) /
         (spatial_grid.domain.domain[2] - spatial_grid.domain.domain[1])) *
        spatial_grid.ncells)
    return Grid(time_domain, ncells_t)
end

end # end of module

module Grids

import ..Domains
import ..Utils

struct Grid{T<:Real,S<:Real,R<:Integer}
    domain::Domains.Domain{T}
    ncells::R
    npoints::R
    coords::Vector{S}
    spacing::S
end

function Grid(domain::Domains.Domain{<:Real},
              ncells::Integer)::Grid{<:Real,<:Real,<:Integer}
    npoints = ncells + 1
    coords = Utils.discretize(domain.dmin, domain.dmax, ncells)
    spacing = Utils.spacing(domain, ncells)
    return Grid(domain, ncells, npoints, collect(typeof(spacing), coords), spacing)
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
    x::Vector{S}
    y::Vector{S}
    z::Vector{S}
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

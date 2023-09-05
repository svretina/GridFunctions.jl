module Grids

using StaticArrays
import Base.length

export UniformGrid, length, spacing, coords, dims

abstract type AbstractGrid{T} end

struct UniformGrid1d{T<:Real} <: AbstractGrid{T}
    domain::SVector{2,T}
    ncells::T
end

function UniformGrid1d(d::AbstractVector{T}, ncells::T) where {T<:Real}
    return UniformGrid1d(SVector{2,T}(d), ncells)
end

function length(g::UniformGrid1d)
    return g.ncells + 1
end

function spacing(xi::T, xn::T, ncells::Integer)::Real where {T<:Real}
    return (xn - xi) / ncells  # (n+1 -1)
end

function spacing(x::AbstractVector{<:Real})
    spacing(x[begin], x[end], length(x) - 1)
end

function spacing(g::UniformGrid1d{T}) where {T<:Real}
    spacing(g.domain[1], g.domain[2], g.ncells)
end

# should this return collect(u)?
function coords(ui::Real, uf::Real, ncells::Real)::AbstractArray{<:Real}
    du = spacing(ui, uf, ncells)
    ns = 0:1:ncells
    u = @. ui + ns * du
    return u
end

function coords(domain::AbstractVector{T}, ncells::T) where {T<:Real}
    return coords(domain[1], domain[2], ncells)
end

function coords(g::UniformGrid1d{<:Real})::AbstractArray{<:Real}
    return coords(g.domain, g.ncells)
end


struct UniformGrid{T<:Real} <: AbstractGrid{T}
    domain::AbstractVector{<:AbstractVector{T}}
    ncells::AbstractVector{T}
end

function coords(g::UniformGrid{<:Real})
    return coords.(g.domain, g.ncells)
end


function dims(g::UniformGrid)
    return length(g.ncells)
end

function UniformGrid(domains::AbstractVector{<:AbstractVector{T}}, ncells::T) where {T<:Real}
    ncells2 = ncells * @SVector ones(T, length(domains))
    return UniformGrid(domains, ncells2)
end

function UniformGrid(domain::AbstractVector{T}, ncells::T, dim::T) where {T<:Real}
    ncells2 = ncells * @SVector ones(T, dim)
    # is AbstractVector correct here or does it need concrete type?
    domains = Array{SVector{2,T}}(undef, dim)
    for i in 1:dim
        domains[i] = domain
    end
    return UniformGrid(domains, ncells2)
end

function UniformGrid(domain::AbstractVector{T}, ncells::T) where {T<:Real}
    return UniformGrid1d(domain, ncells)
end

function length(g::UniformGrid{T}) where {T<:Real}
    return g.ncells .+ 1
end

# function UniformGrid(domain::AbstractVector{T}, ncells::T, dims::T) where {T<:Real}
#     ncells2 = ncells * @SVector ones(T, dims)
#     # is AbstractVector correct here or does it need concrete type?
#     domains = SizedVector{dims,AbstractVector{T}}(undef)
#     for i in 1:dims
#         domains[i] = domain
#     end
#     return UniformGrid(domains, ncells2)
# end

# function dims(g::UniformGrid)
#     return length(g.grids)
# end

# Isotropic case

# function UniformGrid(domains::AbstractVector{<:AbstractVector{T}}, ncells::T) where {T<:Real}
#     ncells2 = ncells * @SVector ones(T, length(domains))
#     return UniformGrid(domains, ncells2)
# end

# Anisotropic case
# function UniformGrid(domains::AbstractVector{<:AbstractVector{T}}, ncells::AbstractVector{T}) where {T<:Real}
#     dim = length(ncells)
#     dim == length(domains) || throw(DimensionMismatch("Length of domains and ncells must match."))
#     # grids = Array{UniformGrid1d{T}}(undef, dim)
#     grids = SizedVector{dim,UniformGrid1d{T}}(undef)
#     for i in 1:dim
#         grids[i] = UniformGrid1d(domains[i], ncells[i])
#     end
#     # return UniformGrid(SVector{dim,UniformGrid1d{T}}(grids))
#     return UniformGrid(grids)
# end

# function coords(g::UniformGrid)
#     return coords.(g.grids)
# end

# function spacing(g::UniformGrid)
#     return spacing.(g.grids)
# end

# function length(g::UniformGrid)
#     return length.(g.grids)
# end

# function ncells(g::UniformGrid)
#     return length(g) .- 1
# end

# function domain(g::UniformGrid{T}) where {T<:Real}
#     dim = length(g.grids)
#     domains = SizedVector{dim,AbstractVector{T}}(undef)
#     for i in 1:dim
#         domains[i] = g.grids[i].domain
#     end
#     return domains
# end

# struct UniformGrid{T<:Real} <: AbstractGrid{T}
#     grids::AbstractVector{<:UniformGrid1d{T}}
# end

###########################################################################
# """
#     UniformGrid1d(domain::Domains.Domain{<:Real},
#     ncells::Integer)::UniformGrid{<:Real,<:Real,<:Integer}

# Grid constructor called with a Domain type and number of cells (`ncells`)
# # Examples
# ```julia-repl
# julia> d = GridFunctions.Domains.Domain([0,1])
# GridFunctions.Domains.Domain{Int64}([0, 1], 0, 1)
# julia> g = GridFunctions.Grids.UniformGrid(d, 10)
# GridFunctions.Grids.UniformGrid{Int64, Float64, Int64}(GridFunctions.Domains.Domain{Int64}([0, 1], 0, 1), 10, 11, [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0], 0.1)
# ```
# """
# function UniformGrid1d(domain::Domains.Domain{<:Real}, ncells::Integer)::UniformGrid1d
#     npoints = ncells + 1
#     coords = Utils.discretize(domain.dmin, domain.dmax, ncells)
#     spacing = Utils.spacing(domain, ncells)
#     ## is collect a good choice?
#     ## collect(typeof(spacing), coords
#     return UniformGrid1d(domain, ncells, npoints, spacing, coords)
# end

# # """
# #     Base.show(io::IO, g::Grid)

# # Overloads Base.show to custom print Grid
# # """
# # function Base.show(io::IO, g::UniformGrid)
# #     dump(g)
# # end

# # """
# #     Base.show(io::IO, ::MIME"text/plain", g::Grid)

# # Overloads Base.show to custom print Grid in REPL
# # """
# # function Base.show(io::IO, ::MIME"text/plain", g::UniformGrid{T,S,R}) where {T,S,R}
# #     println(UniformGrid{T,S,R})
# #     println("domain = SVector{$T}$(g.domain.domain)")
# #     # println("ncells = $(g.ncells)")
# #     println("npoints = $(g.npoints)")
# #     println("spacing = $(g.spacing)")
# #     println("coords = $(g.coords)")
# # end

# # function Grid(domain::Domains.Domain{<:Rational}, ncells::Integer)::Grid
# #     npoints = ncells + 1
# #     coords = Utils.discretize(domain.dmin, domain.dmax, ncells)
# #     spacing = Utils.spacing(domain, ncells)
# #     return Grid(domain, ncells, npoints, collect(coords), spacing)
# # end

# import Base
# function Base.convert(::Type{T}, g::UniformGrid1d)::UniformGrid1d{<:Real,<:Real,<:Integer} where {T<:Real}
#     UniformGrid1d(convert(T, g.domain), g.ncells)
# end

# ## currently only a cube domain is supported
# ## dx=dy=dz
# ## nx=ny=nz
# ## Make it use Grid for xyz
# struct Grid3D{T<:Real,S<:Real,R<:Integer}
#     domain::Domains.Domain3D{T}
#     ncells::R
#     npoints::R
#     x::AbstractVector{S}
#     y::AbstractVector{S}
#     z::AbstractVector{S}
#     spacing::S
# end

# function Grid3D(domain::Domains.Domain3D{<:Real},
#     ncells::Integer)::Grid3D{<:Real,<:Real,<:Integer}
#     npoints = ncells + 1
#     coords = Utils.discretize(domain.xmin, domain.xmax, ncells)
#     spacing = Utils.spacing(domain.domain[1], ncells)
#     T = typeof(spacing)
#     x = collect(T, coords)
#     y = collect(T, coords)
#     z = collect(T, coords)
#     return Grid3D(domain, ncells, npoints, x, y, z, spacing)
# end

# function TimeGrid_from_cfl(spatial_grid::UniformGrid1d, time_domain::Domains.Domain, cfl::Real)::UniformGrid1d
#     ncells_t = ceil(Int64,
#         (1 / cfl) *
#         ((time_domain.domain[2] - time_domain.domain[1]) /
#          (spatial_grid.domain.domain[2] - spatial_grid.domain.domain[1])) *
#         spatial_grid.ncells)
#     return UniformGrid1d(time_domain, ncells_t)
# end

end # end of module

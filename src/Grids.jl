module Grids

using StaticArrays
import Base.length

export UniformGrid, UniformGrid1D, spacing, coords, UniformStaggeredGrid1D

abstract type AbstractGrid{T,N} <: AbstractArray{T,N} end

abstract type AbstractCollocatedGrid{T,N} <: AbstractGrid{T,N} end
abstract type AbstractStaggeredGrid{T,N} <: AbstractGrid{T,N} end

struct UniformGrid1D{T<:Real} <: AbstractCollocatedGrid{T,1}
    domain::SVector{2,T}
    ncells::Int64
end

struct UniformStaggeredGrid1D{T<:Real} <: AbstractStaggeredGrid{T,1}
    domain::SVector{2,T}
    ncells::Int64
end

@inline function Base.getindex(g::UniformGrid1D, i::Int)
    h = spacing(g)
    return (g.domain[1]:h:g.domain[end])[i]
end

@inline function Base.getindex(g::UniformStaggeredGrid1D, i::Int)
    h = spacing(g)
    return ((g.domain[1] + 0.5h):h:(g.domain[end] - 0.5h))[i]
end

@inline function Base.similar(g::UniformGrid1D)
    return UniformGrid1D(similar(g.domain), g.ncells)
end

function UniformGrid1D(d::AbstractVector{T}, ncells::Int) where {T<:Real}
    return UniformGrid1D(SVector{2,T}(d), ncells)
end

function UniformStaggeredGrid1D(d::AbstractVector{T}, ncells::Int) where {T<:Real}
    return UniformStaggeredGrid1D(SVector{2,T}(d), ncells)
end

function spacing(xi::T, xn::T, ncells::Integer) where {T<:Real}
    return (xn - xi) / ncells  # (n+1 -1)
end

function spacing(x::AbstractVector{<:Real})
    return spacing(x[begin], x[end], length(x) - 1)
end

function spacing(g::AbstractGrid{T,1}) where {T<:Real}
    return spacing(g.domain[1], g.domain[2], g.ncells)
end

function coords(ui::Real, uf::Real, ncells::Real)
    h = spacing(ui, uf, ncells)
    return collect(ui:h:uf)
end

function coords(domain::AbstractVector{T}, ncells::Int) where {T<:Real}
    length(domain) === 2 || throw(DimensionMismatch("domain needs to be Vector of length 2"))
    return coords(domain[1], domain[2], ncells)
end

function coords(g::UniformGrid1D{<:Real})
    return coords(g.domain, g.ncells)
end

function coords(g::AbstractStaggeredGrid{T,1}) where {T}
    return cell_center_coords(g)
end

# should be (ncells + 1) faces
function face_coords(g::UniformStaggeredGrid1D{<:Real})
    return coords(g.domain, g.ncells)
end

function cell_center_coords(g::UniformStaggeredGrid1D{T}) where {T}
    h = spacing(g)
    return collect((g.domain[1] + 0.5h):h:(g.domain[end] - 0.5h))
end

##########################
## multidimensional grids.
struct UniformGrid{T<:Real,N<:Int} <: AbstractGrid{T,N}
    domain::AbstractVector{<:AbstractVector{T}}
    ncells::AbstractVector{<:Int}
end

function coords(g::UniformGrid{<:Real})
    return coords.(g.domain, g.ncells)
end

function UniformGrid(domains::AbstractVector{<:AbstractVector{T}}, ncells::Int) where {T<:Real}
    n = length(domains)
    ncells2 = ncells * @SVector ones(Int64, n)
    domains = SVector{n,SVector{2,T}}(domains)
    return UniformGrid(domains, ncells2)
end

function UniformGrid(domain::AbstractVector{T}, ncells::Int, dim::Int) where {T<:Real}
    ncells2 = ncells * @SVector ones(Int64, dim)
    domains = Array{SVector{2,T}}(undef, dim)
    for i in 1:dim
        domains[i] = domain
    end
    return UniformGrid(SVector{dim,SVector{2,T}}(domains), ncells2)
end

function UniformGrid(domain::AbstractVector{T}, ncells::Int) where {T<:Real}
    return UniformGrid1D(domain, ncells)
end

end # end of module

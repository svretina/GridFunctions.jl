module Grids

using StaticArrays
import Base.length

export UniformGrid, spacing, coords

abstract type AbstractGrid{T} end

struct UniformGrid1d{T<:Real} <: AbstractGrid{T}
    domain::SVector{2,T}
    ncells::T
end

function UniformGrid1d(d::AbstractVector{T}, ncells::T) where {T<:Real}
    return UniformGrid1d(SVector{2,T}(d), ncells)
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

function coords(ui::Real, uf::Real, ncells::Real)::AbstractArray{<:Real}
    du = spacing(ui, uf, ncells)
    ns = 0:1:ncells
    u = @. ui + ns * du
    return collect(u)
end

function coords(domain::AbstractVector{T}, ncells::T) where {T<:Real}
    length(domain) === 2 || throw(DimensionMismatch("domain needs to be Vector of length 2"))
    return coords(domain[1], domain[2], ncells)
end

function coords(g::UniformGrid1d{<:Real})::AbstractArray{<:Real}
    return coords(g.domain, g.ncells)
end


struct UniformGrid{T<:Real} <: AbstractGrid{T}
    domain::AbstractVector{<:AbstractVector{T}}
    ncells::AbstractVector{<:Int}
end

function coords(g::UniformGrid{<:Real})
    return coords.(g.domain, g.ncells)
end

function UniformGrid(domains::AbstractVector{<:AbstractVector{T}}, ncells::T) where {T<:Real}
    n = length(domains)
    ncells2 = ncells * @SVector ones(T, n)
    domains = SVector{n,SVector{2,T}}(domains)
    return UniformGrid(domains, ncells2)
end

function UniformGrid(domain::AbstractVector{T}, ncells::T, dim::T) where {T<:Real}
    ncells2 = ncells * @SVector ones(T, dim)
    domains = Array{SVector{2,T}}(undef, dim)
    for i in 1:dim
        domains[i] = domain
    end
    return UniformGrid(SVector{dim,SVector{2,T}}(domains), ncells2)
end

function UniformGrid(domain::AbstractVector{T}, ncells::T) where {T<:Real}
    return UniformGrid1d(domain, ncells)
end

end # end of module

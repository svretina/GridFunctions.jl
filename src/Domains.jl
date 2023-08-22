module Domains

using StaticArrays
"""
Struct to hold information about the physical
domain of the numerical grid.

- domain:  the physical domain e.g [0,1]
- dmin: the minimum of the domain
- dmax: the maximum of the domain
"""
struct Domain{T<:Real}
    domain::SVector{2,T}
    dmin::T
    dmax::T
end

## Constructor overloading to calculate dims from domain array
function Domain(dom::Vector{T})::Domain{T} where {T<:Real}
    @assert dom[1] < dom[2] || throw("Domain must be sorted from small to big.")
    dmin = min(dom[begin], dom[end])
    dmax = max(dom[begin], dom[end])
    return Domain(SVector{2}(dom), dmin, dmax)
end

function Domain(dom::SVector{2,T})::Domain{T} where {T<:Real}
    @assert dom[1] < dom[2] || throw("Domain must be sorted from small to big.")
    dmin = min(dom[begin], dom[end])
    dmax = max(dom[begin], dom[end])
    return Domain(dom, dmin, dmax)
end

function Domain(::Type{T}, dom::AbstractVector{<:Real})::Domain{T} where {T<:Real}
    Domain(convert.(T, dom))
end

import Base

using StaticArrays

function Base.convert(::Type{T}, dom::Domain)::Domain{T} where {T<:Real}
    Domain(convert.(T, dom.domain))
end

struct Domain3D{T<:Real}
    domain::SVector{3,Domain{T}}
    xmin::T
    xmax::T
    ymin::T
    ymax::T
    zmin::T
    zmax::T
end

## Constructor overloading to calculate dims from domain array
@inbounds function Domain3D(dom::Vector{<:Domain{T}})::Domain3D{T} where {T<:Real}
    @assert dom[1].domain[1] < dom[1].domain[2] &&
            dom[2].domain[1] < dom[2].domain[2] &&
            dom[3].domain[1] < dom[3].domain[2] ||
            throw("Domain must be sorted from small to big.")
    xmin = dom[1].dmin
    xmax = dom[1].dmax
    ymin = dom[2].dmin
    ymax = dom[2].dmax
    zmin = dom[3].dmin
    zmax = dom[3].dmax
    return Domain3D(SVector{3,Domain{T}}(dom), xmin, xmax, ymin, ymax, zmin, zmax)
end

@inbounds function Domain3D(dom::SVector{3,<:Domain{T}})::Domain3D{T} where {T<:Real}
    @assert dom[1].domain[1] < dom[1].domain[2] &&
            dom[2].domain[1] < dom[2].domain[2] &&
            dom[3].domain[1] < dom[3].domain[2] ||
            throw("Domain must be sorted from small to big.")
    xmin = dom[1].dmin
    xmax = dom[1].dmax
    ymin = dom[2].dmin
    ymax = dom[2].dmax
    zmin = dom[3].dmin
    zmax = dom[3].dmax
    return Domain3D(dom, xmin, xmax, ymin, ymax, zmin, zmax)
end

function Domain3D(::Type{T},
                  dom::AbstractVector{Domain{S}})::Domain3D{T} where {T<:Real,S<:Real}
    Domain3D(convert.(T, dom))
end

function Base.convert(::Type{T}, dom::Domain3D)::Domain3D{T} where {T<:Real}
    Domain3D(convert.(T, dom.domain))
end

end

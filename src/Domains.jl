module Domains

using StaticArrays

abstract type AbstractDomain end

"""
Struct to hold information about the physical
domain of the numerical grid.

- domain:  the physical domain e.g [0,1]
- dmin: the minimum of the domain
- dmax: the maximum of the domain
"""
# interval domain -> chang to interval
struct IntervalDomain{T<:Real} <: AbstractDomain
    domain::SVector{2,T}
end

## Constructor overloading to calculate dims from domain array
"""
    Domain(dom::Vector{T})::Domain{T} where {T<:Real}

Constructor with a domain provided as AbstractVector
"""
function Domain(dom::AbstractVector{T})::Domain{T} where {T<:Real}
    @assert dom[1] < dom[2] || throw("Domain must be sorted from small to big.")
    dmin = min(dom[begin], dom[end])
    dmax = max(dom[begin], dom[end])
    return Domain(SVector{2}(dom))
end

"""
    Domain(dom::SVector{2,T})::Domain{T} where {T<:Real}

Constructor with a domain provided as StaticArrays' SVector
"""
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

function Base.convert(::Type{T}, dom::Domain)::Domain{T} where {T<:Real}
    Domain(convert.(T, dom.domain))
end

# function Base.show(io::IO, d::Domain)
#     # dump(d)
#     # println("domain: $(d.domain)")
# end

# function Base.show(io::IO, ::MIME"text/plain", d::Domain{T}) where {T}
#     println(Domain{T})
#     println("domain = $(typeof(d.domain)) $(d.domain)")
# end

# Implement the following
# function print_interval(io::IO, domain::IntervalDomain{CT}) where {CT}
#     print(
#         io,
#         fieldname(CT, 1),
#         " ∈ [",
#         Geometry.component(domain.coord_min, 1),
#         ",",
#         Geometry.component(domain.coord_max, 1),
#         "] ",
#     )
#     if isperiodic(domain)
#         print(io, "(periodic)")
#     else
#         print(io, domain.boundary_names)
#     end
# end
# function Base.show(io::IO, domain::IntervalDomain)
#     print(io, nameof(typeof(domain)), ": ")
#     print_interval(io, domain)
# end
## 3D
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

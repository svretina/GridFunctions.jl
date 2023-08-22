module Utils

import ..Domains

function discretize(ui::T, uf::T, nu::S)::AbstractArray{<:Real} where {T<:Real,S<:Real}
    du = spacing(ui, uf, nu)
    try
        du = T(du)
    catch e
        du = du
    end
    ns = 0:1:nu
    u = @. ui + ns * du
    return u
end

# this crashes the memory (?)
# function discretize(ui::Real, uf::Real, nu::Integer)::AbstractArray{<:Real}
#     return discretize(promote(ui, uf)..., nu)
# end

function spacing(x::AbstractVector{<:Real})
    spacing(x[begin], x[end], length(x) - 1)
end

function spacing(xi::T, xn::T, ncells::Integer)::Real where {T<:Real}
    return (xn - xi) / ncells  # (n+1 -1)
end

function spacing(domain::Domains.Domain{T}, ncells::Integer)::Real where {T<:Real}
    return spacing(domain.dmin, domain.dmax, ncells)
end

end

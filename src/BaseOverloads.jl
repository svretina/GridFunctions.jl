module BaseOverloads

import ..Grids
import ..Functions

## Grids
import Base.==
function ==(g1::Grids.AbstractGrid, g2::Grids.AbstractGrid)
    return all((g1.domain == g2.domain, g1.ncells == g2.ncells))
end



import Base.eltype
function eltype(g::Grids.AbstractGrid{T,N}) where {T<:Real,N}
    return eltype(eltype(g.domain))
end

import Base.ndims
function ndims(g::Grids.AbstractGrid{T,N}) where {T,N}
    return length(g.ncells)
end

# Removed redundant ndims(AbstractCollocatedGrid)

import Base.size
# Size now handled by specific struct implementations in Grids.jl (RectilinearGrid)
# and for UniformGrid1D below.


import Base.iterate
function iterate(g::Grids.AbstractGrid)
    return iterate(Grids.coords(g))
end

function iterate(g::Grids.AbstractGrid, state)
    return iterate(Grids.coords(g), state)
end

## GridFunctions
import Base.isapprox
function isapprox(gf::Functions.GridFunction, number::Number; atol::Real=0, rtol::Real=0,
                  nans::Bool=false, norm::Function=abs)
    return all(isapprox.(gf.values, number; atol, rtol, nans, norm))
end

function isapprox(number::Number, gf::Functions.GridFunction; atol::Real=0, rtol::Real=0,
                  nans::Bool=false, norm::Function=abs)
    return all(isapprox.(number, gf.values; atol, rtol, nans, norm))
end

function isapprox(gf1::Functions.GridFunction, gf2::Functions.GridFunction;
                  atol::Real=0, rtol::Real=0, nans::Bool=false, norm::Function=abs)
    gf1.grid == gf2.grid || throw(DimensionMismatch("x's are not the same"))
    return all(isapprox.(gf1.values, gf2.values; atol, rtol, nans, norm))
end

math_operators = [:+, :-, :*, :/, :^]
for op in math_operators
    @eval import Base.$op
    @eval function $op(gf::Functions.GridFunction, number::Number)
        Functions.GridFunction(gf.grid, @. $op(gf.values, number))
    end

    @eval function $op(number::Number, gf::Functions.GridFunction)
        Functions.GridFunction(gf.grid, @. $op(number, gf.values))
    end

    @eval begin
        function $op(gf1::Functions.GridFunction, gf2::Functions.GridFunction)
            gf1.grid == gf2.grid || throw(DimensionMismatch("x's not the same"))
            return Functions.GridFunction(gf1.grid, @. $op(gf1.values, gf2.values))
        end
    end
end

logical_operators = [:<, :(==), :<=]
for op in logical_operators
    @eval import Base.$op
    @eval function $op(gf::Functions.GridFunction, number::Number)
        all(@. $op(gf.values, number))
    end

    @eval function $op(number::Number, gf::Functions.GridFunction)
        all(@. $op(number, gf.values))
    end

    @eval begin
        function $op(gf1::Functions.GridFunction, gf2::Functions.GridFunction)
            gf1.grid == gf2.grid || throw(DimensionMismatch("x's not the same"))
            return $op(gf1.values, gf2.values)
        end
    end
end

math_functions = [:sin, :cos, :tan, :asin, :acos, :atan, :sinh, :cosh, :tanh, :asinh,
                  :acosh, :atanh, :sec, :csc, :cot, :asec, :acsc, :acot, :sech, :csch,
                  :coth, :asech, :acsch, :acoth, :sinpi, :cospi, :sinc, :cosc, :log, :log2,
                  :log10, :exp, :exp2, :abs, :abs2, :sqrt, :cbrt, :inv, :+, :-]

for op in math_functions
    @eval import Base.$op
    @eval function $op(gf::Functions.GridFunction)
        Functions.GridFunction(gf.grid, @. $op(gf.values))
    end
end

for op in math_functions
    @eval import Base.$op
    @eval function $op(g::Grids.AbstractGrid)
        $op.(Grids.coords(g))
    end
end

reductions = [:max, :min]
for op in reductions
    @eval import Base.$op
    @eval $op(gf::Functions.GridFunction) = $op(gf.values...)
end

import Base.Broadcast.broadcastable
broadcastable(gf::Functions.GridFunction) = broadcastable(gf.values)


# -----------------------------------------------------------
# Indexing
# -----------------------------------------------------------

# Helper to wrap indices for Periodic
@inline function wrap_index(i::Int, n::Int)
    return mod1(i, n)
end

# 1. NonPeriodic: Direct access (let Array handle bounds checks)
@inline function Base.getindex(f::Functions.GridFunction{T,N,<:Any,<:Any,Grids.NonPeriodic}, I::Vararg{Int, N}) where {T,N}
    @boundscheck checkbounds(f.values, I...)
    @inbounds return f.values[I...]
end

@inline function Base.setindex!(f::Functions.GridFunction{T,N,<:Any,<:Any,Grids.NonPeriodic}, v, I::Vararg{Int, N}) where {T,N}
    @boundscheck checkbounds(f.values, I...)
    @inbounds f.values[I...] = v
end

# 2. Periodic: Wrap indices
@inline function Base.getindex(f::Functions.GridFunction{T,N,<:Any,<:Any,Grids.Periodic}, I::Vararg{Int, N}) where {T,N}
    sz = size(f.values)
    return f.values[map(wrap_index, I, sz)...]
end

@inline function Base.setindex!(f::Functions.GridFunction{T,N,<:Any,<:Any,Grids.Periodic}, v, I::Vararg{Int, N}) where {T,N}
    sz = size(f.values)
    f.values[map(wrap_index, I, sz)...] = v
end

# 3. Linear Indexing (Forward to cartesian if possible, or just linear access)
# For Periodic linear indexing in ND, it's ambiguous/complex to wrap correctly unless we convert to Cartesian.
# We will support linear indexing as direct access (no wrapping) for now, or assume 1D.
# If N=1, linear IS cartesian.
@inline function Base.getindex(f::Functions.GridFunction{T,1,<:Any,<:Any,Grids.Periodic}, i::Int) where {T}
    sz = length(f.values)
    return f.values[wrap_index(i, sz)]
end

@inline function Base.setindex!(f::Functions.GridFunction{T,1,<:Any,<:Any,Grids.Periodic}, v, i::Int) where {T}
    sz = length(f.values)
    f.values[wrap_index(i, sz)] = v
end

@inline function Base.getindex(f::Functions.GridFunction{T,1,<:Any,<:Any,Grids.NonPeriodic}, i::Int) where {T}
    return f.values[i]
end

@inline function Base.setindex!(f::Functions.GridFunction{T,1,<:Any,<:Any,Grids.NonPeriodic}, v, i::Int) where {T}
    f.values[i] = v
end

# Fallback for linear indexing on ND arrays (Non-wrapping behavior for performance/simplicity)
# Users should use cartesian indexing f[i, j] for physics logic.
@inline function Base.getindex(f::Functions.GridFunction, i::Int)
    return f.values[i]
end

@inline function Base.setindex!(f::Functions.GridFunction, v, i::Int)
    f.values[i] = v
end

function Base.size(f::Functions.GridFunction)
    # Use the grid size, which defines the "logical" size.
    # For NonPeriodic, it's ncells+1. For Periodic, it might be interpreted differently
    # but the implementation of GridFunction values usually stores ncells+1 points for convenience?
    # Actually, GridFunction wraps `values`. `values` has the true size.
    return size(f.values)
end

function Base.lastindex(f::Functions.GridFunction)
    return length(f.values)
end

# Base.convert(::Type{T}, g::Grids.AbstractGrid{T,N}) where {T,N} =

# Base.convert(::Type{T}, g::Grids.AbstractGrid{T}) where {T} = g
# Base.convert(::Type{T}, g::Grids.AbstractGrid{S}) where {T<:Real,S<:Real} = g.domain = convert.(T, g.domain)

# Base.promote_rule(::Type{Grids.AbstractGrid{T}}, ::Type{S}) where {T,S} = Grids.AbstractGrid{promote_type(T, S)}
# Base.promote_rule(::Type{S}, ::Type{Grids.AbstractGrid{T}}) where {T,S} = Grids.AbstractGrid{promote_type(T, S)}

end # end of module

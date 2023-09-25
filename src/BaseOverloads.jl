module BaseOverloads

import ..Grids
import ..Functions


## Grids
import Base.==
function ==(g1::Grids.AbstractGrid, g2::Grids.AbstractGrid)
    return all((g1.domain == g2.domain, g1.ncells == g2.ncells))
end

import Base.length
function length(g::Grids.UniformGrid1d)
    return g.ncells + 1
end

import Base.size
function size(g::Grids.UniformGrid1d)
    return (g.ncells .+ 1,)
end

import Base.eltype
function eltype(g::Grids.UniformGrid1d{T}) where {T<:Real}
    return eltype(g.domain)
end

function eltype(g::Grids.UniformGrid{T}) where {T<:Real}
    return eltype(eltype(g.domain))
end

import Base.ndims
function ndims(g::Grids.UniformGrid)
    return length(g.ncells)
end

import Base.ndims
function ndims(g::Grids.UniformGrid1d)
    return 1
end

import Base.size
function size(g::Grids.UniformGrid)
    return Tuple(g.ncells .+ 1)
end

import Base.iterate
function iterate(g::Grids.AbstractGrid)
    return iterate(Grids.coords(g))
end

function iterate(g::Grids.AbstractGrid, state)
    return iterate(Grids.coords(g), state)
end

## GridFunctions
import Base.isapprox
function isapprox(gf::Functions.GridFunction, number; atol::Real=0, rtol::Real=0,
    nans::Bool=false, norm::Function=abs)
    return all(isapprox.(gf.values, number; atol, rtol, nans, norm))
end

function isapprox(number, gf::Functions.GridFunction; atol::Real=0, rtol::Real=0,
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
    @eval function $op(gf::Functions.GridFunction, number)
        Functions.GridFunction(gf.grid, @. $op(gf.values, number))
    end

    @eval function $op(number, gf::Functions.GridFunction)
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
    @eval function $op(gf::Functions.GridFunction, number)
        all(@. $op(gf.values, number))
    end

    @eval function $op(number, gf::Functions.GridFunction)
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

end # end of module

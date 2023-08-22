module Base

import ..Domains
import ..Grids
import ..Functions

#################
## isapprox
#################
import Base.isapprox
function Base.isapprox(gf::Functions.GridFunction, number; atol::Real=0, rtol::Real=0,
    nans::Bool=false, norm::Function=abs)
    return all(isapprox.(gf.y, number; atol, rtol, nans, norm))
end

function Base.isapprox(number, gf::Functions.GridFunction; atol::Real=0, rtol::Real=0,
    nans::Bool=false, norm::Function=abs)
    return all(isapprox.(number, gf.y; atol, rtol, nans, norm))
end

function Base.isapprox(gf1::Functions.GridFunction, gf2::Functions.GridFunction;
    atol::Real=0, rtol::Real=0, nans::Bool=false, norm::Function=abs)
    gf1.x == gf2.x || throw(DimensionMismatch("x's are not the same"))
    return all(isapprox.(gf1.y, gf2.y; atol, rtol, nans, norm))
end

math_operators = [:+, :-, :*, :/, :^]
for op in math_operators
    @eval import Base.$op
    @eval function $op(gf::Functions.GridFunction, number)
        Functions.GridFunction(gf.x, @. $op(gf.y, number))
    end

    @eval function $op(number, gf::Functions.GridFunction)
        Functions.GridFunction(gf.x, @. $op(number, gf.y))
    end

    @eval begin
        function $op(gf1::Functions.GridFunction, gf2::Functions.GridFunction)
            gf1.x == gf2.x || throw(DimensionMismatch("x's not the same"))
            return Functions.GridFunction(gf1.x, @. $op(gf1.y, gf2.y))
        end
    end
end

logical_operators = [:<, :(==), :<=]
for op in logical_operators
    @eval import Base.$op
    @eval function $op(gf::Functions.GridFunction, number)
        all(@. $op(gf.y, number))
    end

    @eval function $op(number, gf::Functions.GridFunction)
        all(@. $op(number, gf.y))
    end

    @eval begin
        function $op(gf1::Functions.GridFunction, gf2::Functions.GridFunction)
            gf1.x == gf2.x || throw(DimensionMismatch("x's not the same"))
            return $op(gf1.y, gf2.y)
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
        Functions.GridFunction(gf.x, @. $op(gf.y))
    end
end

reductions = [:max, :min]
for op in reductions
    @eval import Base.$op
    @eval $op(gf::Functions.GridFunction) = $op(gf.y...)
end

import Base.length
length(g::Grids.Grid) = g.npoints
length(gf::Functions.GridFunction) = length(gf.x)

import Base.Broadcast.broadcastable
broadcastable(gf::Functions.GridFunction) = broadcastable(gf.y)

# import Base.*
# import SparseArrays
# function *(A::SparseArrays.AbstractSparseMatrix, gf::Functions.GridFunction)
#     return *(A, gf.y)
# end

end # end of module

using Test
using GridFunctions


const ITypes = [Int32, Int64]
const FTypes = [Float32, Float64]
const RTypes = [ITypes..., FTypes...]

const d = [0, 1]
const n = 10

@testset "gf_base_isapprox" begin
    for T in RTypes
        g = UniformGrid(T.(d), n)
        a = GridFunction(g, zeros(T, n + 1))
        b = GridFunction(g, zeros(T, n + 1))
        @test isapprox(a, 1e-16, atol=1e-15)
        @test isapprox(1e-16, a, atol=1e-15)
        @test isapprox(a, b, atol=1e-15)

        c = GridFunction(g, fill(1e-16, n + 1))
        @test isapprox(a, c, atol=1e-15)
    end
end
@testset "gf_base_equality" begin
    for T in RTypes
        g = UniformGrid(T.(d), n)
        a = GridFunction(g, zeros(T, n + 1))
        b = GridFunction(g, zeros(T, n + 1))
        @test a == b
        @test a == 0
        @test 0 == a
    end
end

@testset "gf_base_inequality" begin
    for T in RTypes
        g = UniformGrid(T.(d), n)
        a = GridFunction(g, zeros(T, n + 1))
        b = GridFunction(g, ones(T, n + 1))
        @test a != b
        @test b != a
        @test a.values != b.values
        @test a != 1
        @test 1 != a
    end
end

@testset "gf_base_greater" begin
    for T in RTypes
        g = UniformGrid(T.(d), n)
        a = GridFunction(g, zeros(T, n + 1))
        b = GridFunction(g, (1:(n+1)) .+ 5)
        @test b > a
        @test 1 > a
        @test b > 5
        @test a > -1
    end
end
@testset "gf_base_greatereq" begin
    for T in RTypes
        g = UniformGrid(T.(d), n)
        a = GridFunction(g, zeros(T, n + 1))
        b = GridFunction(g, ones(T, n + 1))
        @test b >= a
        @test a >= a
        @test 1 >= a
        @test 3 >= b
        @test b >= 0
    end
end

@testset "gf_base_lesseq" begin
    for T in RTypes
        g = UniformGrid(T.(d), n)
        a = GridFunction(g, zeros(T, n + 1))
        b = GridFunction(g, 1:(n+1))
        @test a <= b
        @test a <= a
        @test a <= 0
        @test a <= 5
        @test 1 <= b
    end
end
@testset "gf_base_less" begin
    for T in RTypes
        g = UniformGrid(T.(d), n)
        a = GridFunction(g, zeros(T, n + 1))
        b = GridFunction(g, (1:(n+1)) .+ 5)
        @test a < b
        @test a < 1
        @test 5 < b
        @test -1 < a
    end
end
@testset "gf_base_addition" begin
    for T in RTypes
        g = UniformGrid(T.(d), n)
        a = GridFunction(g, zeros(T, n + 1))
        b = a + 1
        c = 1 + a
        e = GridFunction(g, ones(T, n + 1))
        @test b == e
        @test a == a + 0
        @test a == 0 + a
        @test a == a + a
        @test a == +a
        @test +a == a
    end
end
@testset "gf_base_substraction" begin
    for T in RTypes
        g = UniformGrid(T.(d), n)
        a = GridFunction(g, ones(T, n + 1))
        b = a - 1
        c = 1 - a
        f = a - a
        e = GridFunction(g, zeros(T, n + 1))
        @test b == e
        @test a == a - 0
        @test -a == 0 - a
        @test f == e
        @test f == 0
        @test b == 0
    end
end

@testset "gf_base_multiplication" begin
    for T in RTypes
        g = UniformGrid(T.(d), n)
        a = GridFunction(g, ones(T, n + 1))
        b = GridFunction(g, ones(T, n + 1))
        @test a == 1 * a
        @test a == a * 1
        @test +a == 1 * a
        @test +a == a * 1
        @test -a == -1 * a
        @test -a == a * (-1)
        @test a + a == 2 * a
        @test a + a == a * 2
        @test 0 == a * 0
        @test 0 == 0 * a
        @test 0 == -a * 0
        @test 0 == 0 * (-a)
        @test 0 == +a * 0
        @test 0 == 0 * (+a)
        @test 5 == 5 * a
        @test -5 == -5 * a
        @test 1 == a * b
        @test 1 == b * a
    end
end

@testset "gf_base_division" begin
    for T in RTypes
        g = UniformGrid(T.(d), n)
        a = GridFunction(g, ones(T, n + 1))
        b = GridFunction(g, ones(T, n + 1))
        @test 0.5 == a / 2
        @test a == a / 1
        @test +a == a / 1
        @test -a == a / (-1)
        @test 5 == 5 / a
        @test -5 == -5 / a
        @test 1 == a / b
        @test 1 == b / a
        @test 1 == a / a
        @test Inf == a / 0
    end
end

@testset "gf_base_power" begin
    for T in RTypes
        g = UniformGrid(T.(d), n)
        a = GridFunction(g, ones(T, n + 1))
        @test 1 == a^1
        @test 1 == a^2
        @test 1 == a^-1
        @test a == a^1
        @test 1 == a^0
        @test 1 == a^a
        @test 1 == 1^a
        @test 0 == 0^a
    end
end

const math_functions = [:sin, :cos, :tan, :atan, :sinh, :cosh, :tanh, :sec, :csc, :cot,
    :asec, :acsc, :acot, :sech, :csch, :coth, :acosh, :acsch, :acoth,
    :sinpi, :cospi, :sinc, :cosc, :log, :log2, :log10, :exp, :exp2,
    :abs, :abs2, :sqrt, :cbrt, :inv]

@testset "gf_base_math" begin
    for T in RTypes
        g = UniformGrid(T.(d) .+ 1, n)
        x = coords(g)
        a = GridFunction(g, x)
        for op in math_functions
            f = @eval $op
            tmp1 = f(a)
            tmp2 = f.(a.values)
            @test isapprox(tmp1, tmp2)
        end
    end
end

const math_functions2 = [:asin, :asinh, :atanh, :acos, :asech]

@testset "gf_base_math2" begin
    for T in RTypes
        g = UniformGrid(T.(d), n)
        x = coords(g)
        a = GridFunction(g, x)
        for op in math_functions2
            f = @eval $op
            tmp1 = f(a)
            tmp2 = f.(a.values)
            @test isapprox(tmp1, tmp2)
        end
    end
end

@testset "grids_base_math" begin
    for T in RTypes
        g = UniformGrid(T.(d) .+ 1, n)
        x = coords(g)
        for op in math_functions
            f = @eval $op
            tmp1 = f(g)
            tmp2 = f.(x)
            @test isapprox(tmp1, tmp2)
        end
    end
end

# @testset "gf_base_sqrt" begin
#     y = [1, 2, 3, 4]
#     a = GridFunctions.Functions.GridFunction([0, 1, 2, 3], y)
#     @test sqrt(a) == sqrt.(y)
#     @test isapprox(a, sqrt(a) * sqrt(a), atol=1e-15)
#     @test isapprox(a, sqrt(a)^2, atol=1e-15)
#     @test isapprox(a, sqrt.(y) .^ 2, atol=1e-15)
# end

# @testset "gf_base_cbrt" begin
#     y = [1, 2, 3, 4]
#     a = GridFunctions.Functions.GridFunction([0, 1, 2, 3], y)
#     @test cbrt(a) == cbrt.(y)
#     @test isapprox(a, cbrt(a) * cbrt(a) * cbrt(a), atol=1e-15)
#     @test isapprox(a, cbrt(a)^3, atol=1e-15)
#     @test isapprox(a, cbrt.(y) .^ 3, atol=1e-15)
# end

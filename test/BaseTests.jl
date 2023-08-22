using Test
using GridFunctions


@testset "gf_base_isapprox" begin
    a = GridFunctions.Functions.GridFunction([0, 1, 2], [0, 0, 0])
    b = GridFunctions.Functions.GridFunction([0, 1, 2], [0, 0, 0])
    @test isapprox(a, 1e-16, atol=1e-15)
    @test isapprox(1e-16, a, atol=1e-15)
    @test isapprox(a, b, atol=1e-15)
    c = GridFunctions.Functions.GridFunction([0, 1, 2], [1e-16, 1e-16, 1e-16])
    @test isapprox(a, c, atol=1e-15)
    d = GridFunctions.Functions.GridFunction([0, 1, 3], [0, 0, 0])
    @test_throws DimensionMismatch isapprox(a, d)
    @test_throws DimensionMismatch isapprox(d, a)
end

@testset "gf_base_equality" begin
    a = GridFunctions.Functions.GridFunction([0, 1, 2], [0, 0, 0])
    b = GridFunctions.Functions.GridFunction([0, 1, 2], [0, 0, 0])
    @test a == b
    @test a == 0
    @test 0 == a
    c = GridFunctions.Functions.GridFunction([0, 1, 3], [0, 0, 0])
    @test_throws DimensionMismatch a == c
    @test_throws DimensionMismatch c == a
end

@testset "gf_base_inequality" begin
    a = GridFunctions.Functions.GridFunction([0, 1, 2], [0, 0, 0])
    b = GridFunctions.Functions.GridFunction([0, 1, 2], [1, 2, 3])
    @test a != b
    @test b != a
    @test a.y != b.y
    @test a != 1
    @test 1 != a
    c = GridFunctions.Functions.GridFunction([0, 1, 3], [0, 0, 0])
    @test_throws DimensionMismatch a != c
    @test_throws DimensionMismatch c != a
end

@testset "gf_base_greater" begin
    a = GridFunctions.Functions.GridFunction([0, 1, 2], [0, 0, 0])
    b = GridFunctions.Functions.GridFunction([0, 1, 2], [1, 2, 3])
    @test b > a
    @test 1 > a
    @test 5 > b
    @test a > -1
    c = GridFunctions.Functions.GridFunction([0, 1, 3], [0, 0, 0])
    @test_throws DimensionMismatch a > c
    @test_throws DimensionMismatch c > a
end

@testset "gf_base_greatereq" begin
    a = GridFunctions.Functions.GridFunction([0, 1, 2], [0, 0, 0])
    b = GridFunctions.Functions.GridFunction([0, 1, 2], [1, 2, 3])
    @test b >= a
    @test a >= a
    @test 1 >= a
    @test 3 >= b
    @test a >= 0
    c = GridFunctions.Functions.GridFunction([0, 1, 3], [0, 0, 0])
    @test_throws DimensionMismatch a >= c
    @test_throws DimensionMismatch c >= a
end

@testset "gf_base_lesseq" begin
    a = GridFunctions.Functions.GridFunction([0, 1, 2], [0, 0, 0])
    b = GridFunctions.Functions.GridFunction([0, 1, 2], [1, 2, 3])
    @test a <= b
    @test a <= a
    @test a <= 0
    @test a <= 5
    @test 1 <= b
    c = GridFunctions.Functions.GridFunction([0, 1, 3], [0, 0, 0])
    @test_throws DimensionMismatch a <= c
    @test_throws DimensionMismatch c <= a
end

@testset "gf_base_less" begin
    a = GridFunctions.Functions.GridFunction([0, 1, 2], [0, 0, 0])
    b = GridFunctions.Functions.GridFunction([0, 1, 2], [1, 2, 3])
    @test a < b
    @test a < 1
    @test b < 5
    @test -1 < a
    c = GridFunctions.Functions.GridFunction([0, 1, 3], [0, 0, 0])
    @test_throws DimensionMismatch a > c
    @test_throws DimensionMismatch c > a
end

@testset "gf_base_addition" begin
    a = GridFunctions.Functions.GridFunction([0, 1, 2], [0, 0, 0])
    b = a + 1
    c = 1 + a
    d = a + a
    e = GridFunctions.Functions.GridFunction([0, 1, 2], [1, 1, 1])
    @test b == e
    @test a == a + 0
    @test a == 0 + a
    @test a == a + a
    @test a == +a
    @test +a == a
end

@testset "gf_base_substraction" begin
    a = GridFunctions.Functions.GridFunction([0, 1, 2], [1, 1, 1])
    b = a - 1
    c = 1 - a
    d = a - a
    e = GridFunctions.Functions.GridFunction([0, 1, 2], [0, 0, 0])
    @test b == e
    @test a == a - 0
    @test -a == 0 - a
    @test d == e
    @test d == 0
    @test b == 0
end

@testset "gf_base_multiplication" begin
    a = GridFunctions.Functions.GridFunction([0, 1, 2], [1, 1, 1])
    b = GridFunctions.Functions.GridFunction([0, 1, 2], [1, 1, 1])

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

@testset "gf_base_division" begin
    a = GridFunctions.Functions.GridFunction([0, 1, 2], [1, 1, 1])
    b = GridFunctions.Functions.GridFunction([0, 1, 2], [1, 1, 1])
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

@testset "gf_base_power" begin
    a = GridFunctions.Functions.GridFunction([0, 1, 2], [1, 1, 1])
    @test 1 == a^1
    @test 1 == a^2
    @test 1 == a^-1
    @test a == a^1
    @test 1 == a^0
    @test 1 == a^a
    @test 1 == 1^a
    @test 0 == 0^a
end

@testset "gf_base_inv" begin
    a = GridFunctions.Functions.GridFunction([0, 1, 2], [1, 1, 1])
    @test 1 / a == inv(a)
end

@testset "gf_base_sin" begin
    y = [1, 2, 3]
    a = GridFunctions.Functions.GridFunction([0, 1, 2], y)
    @test sin(a) == sin.(y)
end

@testset "gf_base_cos" begin
    y = [1, 2, 3]
    a = GridFunctions.Functions.GridFunction([0, 1, 2], y)
    @test cos(a) == cos.(y)
end

@testset "gf_base_tan" begin
    y = [1, 2, 3]
    a = GridFunctions.Functions.GridFunction([0, 1, 2], y)
    @test tan(a) == tan.(y)
end

@testset "gf_base_sinpi" begin
    y = [1, 2, 3]
    a = GridFunctions.Functions.GridFunction([0, 1, 2], y)
    @test sinpi(a) == sinpi.(y)
end

@testset "gf_base_cospi" begin
    y = [1, 2, 3]
    a = GridFunctions.Functions.GridFunction([0, 1, 2], y)
    @test cospi(a) == cospi.(y)
end

@testset "gf_base_sinh" begin
    y = [1, 2, 3]
    a = GridFunctions.Functions.GridFunction([0, 1, 2], y)
    @test sinh(a) == sinh.(y)
end

@testset "gf_base_cosh" begin
    y = [1, 2, 3]
    a = GridFunctions.Functions.GridFunction([0, 1, 2], y)
    @test cosh(a) == cosh.(y)
end

@testset "gf_base_tanh" begin
    y = [1, 2, 3]
    a = GridFunctions.Functions.GridFunction([0, 1, 2], y)
    @test tanh(a) == tanh.(y)
end

@testset "gf_base_asin" begin
    y = [0.1, 0.5, 0.8, 1]
    a = GridFunctions.Functions.GridFunction([0, 1, 2, 3], y)
    @test asin(a) == asin.(y)
end

@testset "gf_base_acos" begin
    y = [0.1, 0.5, 0.8, 1]
    a = GridFunctions.Functions.GridFunction([0, 1, 2, 3], y)
    @test acos(a) == acos.(y)
end

@testset "gf_base_atan" begin
    y = [0.1, 0.5, 0.8, 1]
    a = GridFunctions.Functions.GridFunction([0, 1, 2, 3], y)
    @test atan(a) == atan.(y)
end

@testset "gf_base_sec" begin
    y = [0.1, 0.5, 0.8, 1]
    a = GridFunctions.Functions.GridFunction([0, 1, 2, 3], y)
    @test sec(a) == sec.(y)
end

@testset "gf_base_csc" begin
    y = [0.1, 0.5, 0.8, 1]
    a = GridFunctions.Functions.GridFunction([0, 1, 2, 3], y)
    @test csc(a) == csc.(y)
end

@testset "gf_base_cot" begin
    y = [0.1, 0.5, 0.8, 1]
    a = GridFunctions.Functions.GridFunction([0, 1, 2, 3], y)
    @test cot(a) == cot.(y)
end

@testset "gf_base_asec" begin
    y = [1, 2, 3, 4]
    a = GridFunctions.Functions.GridFunction([0, 1, 2, 3], y)
    @test asec(a) == asec.(y)
end

@testset "gf_base_acsc" begin
    y = [1, 2, 3, 4]
    a = GridFunctions.Functions.GridFunction([0, 1, 2, 3], y)
    @test acsc(a) == acsc.(y)
end

@testset "gf_base_acot" begin
    y = [0.1, 0.5, 0.8, 1]
    a = GridFunctions.Functions.GridFunction([0, 1, 2, 3], y)
    @test acot(a) == acot.(y)
end

@testset "gf_base_sech" begin
    y = [0.1, 0.5, 0.8, 1]
    a = GridFunctions.Functions.GridFunction([0, 1, 2, 3], y)
    @test sech(a) == sech.(y)
end

@testset "gf_base_csch" begin
    y = [0.1, 0.5, 0.8, 1]
    a = GridFunctions.Functions.GridFunction([0, 1, 2, 3], y)
    @test csch(a) == csch.(y)
end

@testset "gf_base_cot" begin
    y = [0.1, 0.5, 0.8, 1]
    a = GridFunctions.Functions.GridFunction([0, 1, 2, 3], y)
    @test coth(a) == coth.(y)
end

@testset "gf_base_asinh" begin
    y = [0.1, 0.5, 0.8, 1]
    a = GridFunctions.Functions.GridFunction([0, 1, 2, 3], y)
    @test asinh(a) == asinh.(y)
end

@testset "gf_base_acosh" begin
    y = [1, 2, 3, 4]
    a = GridFunctions.Functions.GridFunction([0, 1, 2, 3], y)
    @test acosh(a) == acosh.(y)
end

@testset "gf_base_atanh" begin
    y = [0.1, 0.5, 0.8, 1]
    a = GridFunctions.Functions.GridFunction([0, 1, 2, 3], y)
    @test atanh(a) == atanh.(y)
end

@testset "gf_base_asech" begin
    y = [0.1, 0.5, 0.8, 1]
    a = GridFunctions.Functions.GridFunction([0, 1, 2, 3], y)
    @test asech(a) == asech.(y)
end

@testset "gf_base_acsch" begin
    y = [1, 2, 3, 4]
    a = GridFunctions.Functions.GridFunction([0, 1, 2, 3], y)
    @test acsch(a) == acsch.(y)
end

@testset "gf_base_acoth" begin
    y = [1, 2, 3, 4]
    a = GridFunctions.Functions.GridFunction([0, 1, 2, 3], y)
    @test acoth(a) == acoth.(y)
end

@testset "gf_base_sinc" begin
    y = [1, 2, 3, 4]
    a = GridFunctions.Functions.GridFunction([0, 1, 2, 3], y)
    @test sinc(a) == sinc.(y)
end

@testset "gf_base_cosc" begin
    y = [1, 2, 3, 4]
    a = GridFunctions.Functions.GridFunction([0, 1, 2, 3], y)
    @test cosc(a) == cosc.(y)
end

@testset "gf_base_log" begin
    y = [1, 2, 3, 4]
    a = GridFunctions.Functions.GridFunction([0, 1, 2, 3], y)
    @test log(a) == log.(y)
end

@testset "gf_base_exp" begin
    y = [1, 2, 3, 4]
    a = GridFunctions.Functions.GridFunction([0, 1, 2, 3], y)
    @test exp(a) == exp.(y)
end

@testset "gf_base_min" begin
    y = [1, 2, 3, 4]
    a = GridFunctions.Functions.GridFunction([0, 1, 2, 3], y)
    @test min(a) == min(y...)
    @test min(a) == 1
end

@testset "gf_base_max" begin
    y = [1, 2, 3, 4]
    a = GridFunctions.Functions.GridFunction([0, 1, 2, 3], y)
    @test max(a) == max(y...)
    @test max(a) == 4
end

@testset "gf_base_abs" begin
    y = [1, 2, 3, 4]
    a = GridFunctions.Functions.GridFunction([0, 1, 2, 3], y)
    @test abs(a) == abs.(y)
end

@testset "gf_base_abs2" begin
    y = [1, 2, 3, 4]
    a = GridFunctions.Functions.GridFunction([0, 1, 2, 3], y)
    @test abs2(a) == abs.(y) .^ 2
    @test abs2(a) == abs2.(y)
end

@testset "gf_base_sqrt" begin
    y = [1, 2, 3, 4]
    a = GridFunctions.Functions.GridFunction([0, 1, 2, 3], y)
    @test sqrt(a) == sqrt.(y)
    @test isapprox(a, sqrt(a) * sqrt(a), atol=1e-15)
    @test isapprox(a, sqrt(a)^2, atol=1e-15)
    @test isapprox(a, sqrt.(y) .^ 2, atol=1e-15)
end

@testset "gf_base_cbrt" begin
    y = [1, 2, 3, 4]
    a = GridFunctions.Functions.GridFunction([0, 1, 2, 3], y)
    @test cbrt(a) == cbrt.(y)
    @test isapprox(a, cbrt(a) * cbrt(a) * cbrt(a), atol=1e-15)
    @test isapprox(a, cbrt(a)^3, atol=1e-15)
    @test isapprox(a, cbrt.(y) .^ 3, atol=1e-15)
end

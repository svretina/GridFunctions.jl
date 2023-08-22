using Test
using GridFunctions

const ITypes = [Int32, Int64]
const FTypes = [Float32, Float64]

@testset "domain_tests_domain" begin
    @test GridFunctions.Domains.Domain([0, 1]).domain == [0, 1]
end

@testset "domain_tests_minmax" begin
    @test GridFunctions.Domains.Domain([0, 1]).dmin == 0
    @test GridFunctions.Domains.Domain([0, 1]).dmax == 1
end

@testset "domain_type_conversion1" begin
    for T in ITypes
        d = GridFunctions.Domains.Domain([0, 1])
        d = convert(Rational{T}, d)
        @test typeof(d) <: GridFunctions.Domains.Domain{<:Rational}
        @test typeof(d.domain) <: AbstractVector{<:Rational}
        @test typeof(d.dmin) <: Rational
        @test typeof(d.dmax) <: Rational
    end
end
@testset "domain_type_conversion2" begin
    for T in FTypes
        d = GridFunctions.Domains.Domain(Rational.([0, 1]))
        d = convert(T, d)
        @test typeof(d) <: GridFunctions.Domains.Domain{<:AbstractFloat}
        @test typeof(d.domain) <: AbstractVector{<:AbstractFloat}
        @test typeof(d.dmin) <: AbstractFloat
        @test typeof(d.dmax) <: AbstractFloat
    end
end
@testset "domain_construction_with_type" begin
    for T in ITypes
        d = GridFunctions.Domains.Domain(Rational{T}, [0, 1])
        @test typeof(d) <: GridFunctions.Domains.Domain{<:Rational}
        @test typeof(d.domain) <: AbstractVector{<:Rational}
        @test typeof(d.dmin) <: Rational
        @test typeof(d.dmax) <: Rational
    end
end

@testset "domain_construction_with_type" begin
    for T in FTypes
        d = GridFunctions.Domains.Domain(T, [0, 1])
        @test typeof(d) <: GridFunctions.Domains.Domain{<:AbstractFloat}
        @test typeof(d.domain) <: AbstractVector{<:AbstractFloat}
        @test typeof(d.dmin) <: AbstractFloat
        @test typeof(d.dmax) <: AbstractFloat
    end
end

@testset "domain_construction_with_type" begin
    for T in ITypes
        d = GridFunctions.Domains.Domain(T, [0, 1])
        @test typeof(d) <: GridFunctions.Domains.Domain{<:Integer}
        @test typeof(d.domain) <: AbstractVector{<:Integer}
        @test typeof(d.dmin) <: Integer
        @test typeof(d.dmax) <: Integer
    end
end

using Test, MyToolbox
using Base.Iterators

@testset "ziplongest" begin
    @test collect(ziplongest([1,2,3], [1,2])) == [(1,1), (2,2), (3,nothing)]
    @test collect(ziplongest([1,2], [1,2,3])) == collect(zip([1,2,nothing], [1,2,3]))
    @test collect(ziplongest(repeated(1), [1,2,3])) == [(1,1), (1,2), (1,3)]
    @test ziplongest(repeated(1), repeated(2)) == zip(repeated(1), repeated(2))
    @test collect(ziplongest([1], [1,2], [1,2,3]; padval=9)) == [(1,9,9), (1,2,9), (1,2,3)]
end

using ConcurrentSim
using JET
using Test

using InteractiveUtils

@testset "JET checks" begin
    rep = report_package("ConcurrentSim";
        ignored_modules=(
            AnyFrameModule(InteractiveUtils),
        )
    )
    @show rep
    @test length(JET.get_reports(rep)) == 0 # use setup below in case there are warnings
    #@test_broken length(JET.get_reports(rep)) == 0
    #@test length(JET.get_reports(rep)) <= 123
end

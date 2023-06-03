using ConcurrentSim
using JET
using Test

using JET: ReportPass, BasicPass, InferenceErrorReport, UncaughtExceptionReport

using InteractiveUtils

# Custom report pass that ignores `UncaughtExceptionReport`
# Too coarse currently, but it serves to ignore the various
# "may throw" messages for runtime errors we raise on purpose
# (mostly on malformed user input)
struct MayThrowIsOk <: ReportPass end

# ignores `UncaughtExceptionReport` analyzed by `JETAnalyzer`
(::MayThrowIsOk)(::Type{UncaughtExceptionReport}, @nospecialize(_...)) = return

# forward to `BasicPass` for everything else
function (::MayThrowIsOk)(report_type::Type{<:InferenceErrorReport}, @nospecialize(args...))
    BasicPass()(report_type, args...)
end

@testset "JET checks" begin
    rep = report_package("ConcurrentSim";
        report_pass=MayThrowIsOk(),
        ignored_modules=(
            AnyFrameModule(InteractiveUtils),
        )
    )
    @show rep
    @test_broken length(JET.get_reports(rep)) == 0
    @test length(JET.get_reports(rep)) <= 4
end

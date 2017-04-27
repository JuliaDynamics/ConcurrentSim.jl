using SimJulia
using Base.Test

expr = :(begin
  while true
    @yield return a
    a, b = b, a+b
  end
end)

slots = Dict{Symbol, Type}()
slots[:a] = Float64
slots[:b] = Float64
slots[:c] = Float64

SimJulia.transformVars!(expr, keys(slots))

println(Base.remove_linenums!(expr))

expr =:(begin
  @yield return 1
  while true
    @yield return 2
    f(@yield return 3)
    res = @yield return 4
  end
end)

@test SimJulia.transformYield!(expr) == 4

println(Base.remove_linenums!(expr))

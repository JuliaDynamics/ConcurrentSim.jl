using SimJulia
using Base.Test

expr = :(function my_test(a, b)
  nothing
end)

@test SimJulia.getArguments(expr) == Symbol[:my_test,:a,:b]

expr = :(function my_test(a, b) :: Any
  nothing
end)

@test SimJulia.getArguments(expr) == Symbol[:my_test,:a,:b]

expr = :(function my_test(a, b::Float64)
  nothing
end)

@test SimJulia.getArguments(expr) == Symbol[:my_test,:a,:b]

expr = :(function my_test(a, b=1.0)
  nothing
end)

@test SimJulia.getArguments(expr) == Symbol[:my_test,:a,:b]

expr = :(function my_test(a, b::Float64=1.0)
  nothing
end)

@test SimJulia.getArguments(expr) == Symbol[:my_test,:a,:b]

expr = :(function my_test(a; b=1.0)
  nothing
end)

@test SimJulia.getArguments(expr) == Symbol[:my_test,:a,:b]

expr = :(function my_test(a; b::Float64=1.0)
  nothing
end)

@test SimJulia.getArguments(expr) == Symbol[:my_test,:a,:b]

expr = :(function my_test(;a=0.0, b=1.0)
  nothing
end)

@test SimJulia.getArguments(expr) == Symbol[:my_test,:a,:b]

expr = :(function my_test(a::Float64, b::Float64)
  c = a * b
end)

slots = Dict{Symbol, Type}()
slots[:a] = Float64
slots[:b] = Float64
slots[:c] = Float64

@test SimJulia.getSlots(expr, :my_test) == slots

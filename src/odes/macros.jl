function check_dependencies(ex, deps::Array{Bool}, i::Int, x::Symbol)
  if ex isa Expr
    if ex.head == :ref && x == ex.args[1]
      deps[i, ex.args[2]] = true
    else
      for arg in ex.args
        check_dependencies(arg, deps, i, x)
      end
    end
  end
end

macro model(expr::Expr)
  expr.head != :function && error("Expression is not a function definition!")
  args = getArguments(expr)
  func_name = shift!(args)
  f_vec = Vector{Expr}()
  for ex in expr.args[2].args
    ex isa Expr && ex.head == Symbol("=") && push!(f_vec, ex)
  end
  n = length(f_vec)
  deps = zeros(Bool, n, n)
  for ex in expr.args[2].args
    ex isa Expr && ex.head == Symbol("=") && check_dependencies(ex.args[2], deps, ex.args[1].args[2], expr.args[1].args[3])
  end
  esc(:(function $func_name()
      f = Array{Function}($n)
      $((:(f[$(f_vec[i].args[1].args[2])] = ($(expr.args[1].args[2])::TaylorSeries.Taylor1, $(expr.args[1].args[3])::Vector{TaylorSeries.Taylor1}, $(expr.args[1].args[4])::Vector{Float64})->$(f_vec[i].args[2])) for i in 1:length(:($f_vec)))...)
      Model(f, $deps)
    end))
end

macro trigger(expr::Expr)
  expr.head != :function && error("Expression is not a function definition!")
  nothing
end

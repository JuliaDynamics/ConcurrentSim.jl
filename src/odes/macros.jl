macro model(expr::Expr)
  expr.head != :function && error("Expression is not a function definition!")
  args = getArguments(expr)
  func_name = shift!(args)
  f_vec = Vector{Expr}()
  for ex in expr.args[2].args
    ex isa Expr && ex.head == Symbol("=") && push!(f_vec, ex)
  end
  esc(:(function $func_name()
      f = Array{Function}(length($f_vec))
      $((:(f[$(f_vec[i].args[1].args[2])] = (t::TaylorSeries.Taylor1, q::Vector{TaylorSeries.Taylor1}, p::Vector{Float64})->$(f_vec[i].args[2])) for i in 1:length(:($f_vec)))...)
      f
    end))
end

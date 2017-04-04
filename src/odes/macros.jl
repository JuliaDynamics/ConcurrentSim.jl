function check_dependencies(ex, deps::Array{Bool}, i::Int, x::Symbol)
  if ex isa Expr
    if ex.head == :ref && ex.args[1] == x
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
  c_vec = Vector{Expr}()
  a_vec = Vector{Expr}()
  f_vec = Vector{Expr}()
  zc_vec = Vector{Expr}()
  neg_vec = Vector{Expr}()
  pos_vec = Vector{Expr}()
  dx = expr.args[1].args[5]
  p = 0
  for ex in expr.args[2].args
    if ex isa Expr
      if ex.head == Symbol("=")
        if ex.args[1] isa Expr && ex.args[1].head == :ref && ex.args[1].args[1] == dx
          push!(f_vec, ex)
        elseif ex.args[1] isa Symbol
          ex.args[2] isa Expr ? push!(a_vec, ex) : push!(c_vec, ex)
        end
      elseif ex isa Expr && ex.head == :if && ex.args[1].head == :call && ex.args[1].args[1] == :<
        push!(zc_vec, ex.args[1].args[2])
        push!(neg_vec, ex.args[2])
        length(ex.args) == 3 ? push!(pos_vec, ex.args[3]) : Expr()
      end
    end
  end
  println(zc_vec)
  println(neg_vec)
  println(pos_vec)
  n = length(f_vec)
  deps = zeros(Bool, n, n)
  param_deps = zeros(Bool, n, p)
  zc_deps = zeros(Bool, p, n)
  for ex in expr.args[2].args
    ex isa Expr && ex.head == Symbol("=") && ex.args[1] isa Expr && ex.args[1].head == :ref && ex.args[1].args[1] == dx && check_dependencies(ex.args[2], deps, ex.args[1].args[2], expr.args[1].args[3])
  end
  esc(:(function $func_name()
      f = Array{Function}($n)
      $((:(f[$(f_vec[i].args[1].args[2])] = ($(expr.args[1].args[2])::TaylorSeries.Taylor1, $(expr.args[1].args[3])::Vector{TaylorSeries.Taylor1}, $(expr.args[1].args[4])::Vector{Float64})->begin
      $((:($(c)) for c in :($c_vec))...)
      $((:($(a)) for a in :($a_vec))...)
      $(f_vec[i].args[2])
      end) for i in 1:length(:($f_vec)))...)
      Model(f, $deps)
    end))
end

macro zerocrossing(expr::Expr)
  expr.head != :function && error("Expression is not a function definition!")
  nothing
end

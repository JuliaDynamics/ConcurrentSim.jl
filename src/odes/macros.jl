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

function number_parameters(ex, n::Int, p::Symbol)
  if ex isa Expr
    if ex.head == :ref && ex.args[1] == p
      n = max(n, ex.args[2])
    else
      for arg in ex.args
        n = max(n, number_parameters(arg, n, p))
      end
    end
  end
  n
end

function getArguments(expr) :: Vector{Symbol}
  args = Symbol[]
  kws = Symbol[]
  params = Symbol[]
  expr_args = expr.args[1].head == :call ? expr.args[1].args : expr.args[1].args[1].args
  for arg in expr_args
    if isa(arg, Symbol)
      push!(args, arg)
    elseif arg.head == Symbol("::")
      push!(args, arg.args[1])
    elseif arg.head == :kw
      isa(arg.args[1], Symbol) ? push!(kws, arg.args[1]) : push!(kws, arg.args[1].args[1])
    elseif arg.head == :parameters
      for arg2 in arg.args
        isa(arg2.args[1], Symbol) ? push!(params, arg2.args[1]) : push!(params, arg2.args[1].args[1])
      end
    end
  end
  [args; kws; params]
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
        if ex.args[1] isa Expr && ex.args[1].head == :ref && ex.args[1].args[1] == expr.args[1].args[5]
          push!(f_vec, ex)
          p = max(p, number_parameters(ex.args[2], p, expr.args[1].args[4]))
        elseif ex.args[1] isa Symbol
          ex.args[2] isa Expr ? push!(a_vec, ex) : push!(c_vec, ex)
        end
      elseif ex isa Expr && ex.head == :if && ex.args[1].head == :call && ex.args[1].args[1] == :<
        push!(zc_vec, ex.args[1].args[2])
        push!(neg_vec, ex.args[2])
        push!(pos_vec, ex.args[3])
      end
    end
  end
  #println(zc_vec)
  #println(neg_vec)
  #println(pos_vec)
  n = length(f_vec)
  m = length(zc_vec)
  deps = zeros(Bool, n, n)
  param_deps = zeros(Bool, n, p)
  zc_deps = zeros(Bool, m, n)
  rev_zc_deps = zeros(Bool, n, m)
  for ex in f_vec
    check_dependencies(ex.args[2], deps, ex.args[1].args[2], expr.args[1].args[3])
    check_dependencies(ex.args[2], param_deps, ex.args[1].args[2], expr.args[1].args[4])
  end
  for (i, ex) in enumerate(zc_vec)
    check_dependencies(ex, zc_deps, i, expr.args[1].args[3])
  end
  #println(deps)
  #println(param_deps)
  #println(zc_deps)
  esc(:(function $func_name()
      f = Array{Function}($n)
      $((:(f[$(f_vec[i].args[1].args[2])] = ($(expr.args[1].args[2])::TaylorSeries.Taylor1{Float64}, $(expr.args[1].args[3])::Vector{TaylorSeries.Taylor1{Float64}}, $(expr.args[1].args[4])::Vector{Float64})->begin
      $((:($(c)) for c in :($c_vec))...)
      $((:($(a)) for a in :($a_vec))...)
      $(f_vec[i].args[2])
      end) for i in 1:length(:($f_vec)))...)
      zc = Vector{Function}()
      $((:(push!(zc, ($(expr.args[1].args[2])::TaylorSeries.Taylor1{Float64}, $(expr.args[1].args[3])::Vector{TaylorSeries.Taylor1{Float64}}, $(expr.args[1].args[4])::Vector{Float64})->begin
      $((:($(c)) for c in :($c_vec))...)
      $((:($(a)) for a in :($a_vec))...)
      $(f_vec[i].args[2])
    end)) for i in 1:length(:($zc_vec)))...)
      min_handler = Vector{Function}()
      Model(f, zc, $deps, $param_deps)
    end))
end

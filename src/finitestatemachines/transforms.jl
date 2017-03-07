function transformVars!(expr::Expr, symbols::Base.KeyIterator{Dict{Symbol,Type}})
  for i in 1:length(expr.args)
    if expr.head == :kw && i == 1

    elseif expr.head == Symbol(".") && i == 2
      
    elseif isa(expr.args[i], Symbol) && in(expr.args[i], symbols)
      expr.args[i] = :(_fsm.$(expr.args[i]))
    elseif isa(expr.args[i], Expr)
      transformVars!(expr.args[i], symbols)
    end
  end
end

function transformTry!(expr::Expr, n::UInt8=0x00, super::Expr=:(), line_no::Int=0, super_try::Expr=:(), line_try::Int=0) :: UInt8
  for (i, arg) in enumerate(expr.args)
    if isa(arg, Expr)
      if arg.head == :line
        line_no = i+1
        super = expr
      elseif arg.head == :macrocall && arg.args[1] == Symbol("@yield")
        n += one(UInt8)
        if expr == super
          expr.args[i] = :(isa(_ret, Exception) && throw(_ret))
        else
          expr.args[i] = :(_ret)
          insert!(super.args, line_no+1, :(isa(_ret, Exception) && throw(_ret)))
        end
        insert!(super.args, line_no, :(_fsm._state = 0xff))
        insert!(super.args, line_no, arg.args[2])
        insert!(super.args, line_no, :(_fsm._state = $n))
        insert!(super_try.args, line_try, :(@label $(Symbol("_STATE_",:($n)))))
        insert!(super_try.args, line_try, deepcopy(super_try.args[line_try+1]))
        for j in length(super_try.args[line_try].args[1].args):-1:line_no+2
          deleteat!(super_try.args[line_try].args[1].args, j)
        end
        for j in 1:line_no+1
          deleteat!(super_try.args[line_try+2].args[1].args, 1)
        end
        break
      else
        m = transformTry!(arg, n, super, line_no, super_try, line_try)
        if m > n
          n=m
          break
        end
      end
    end
  end
  n
end

function transformYield!(expr::Expr, n::UInt8=0x00, super::Expr=:(), line_no::Int=0) :: UInt8
  for (i, arg) in enumerate(expr.args)
    if isa(arg, Expr)
      if arg.head == :try
        n = transformTry!(arg.args[1], n, super, line_no, expr, i)
        println("hi")
      elseif arg.head == :line
        line_no = i+1
        super = expr
      elseif arg.head == :macrocall && arg.args[1] == Symbol("@yield")
        n += one(UInt8)
        if expr == super
          expr.args[i] = :(_fsm._state = 0xff)
        else
          expr.args[i] = :(_ret)
          insert!(super.args, line_no, :(_fsm._state = 0xff))
        end
        insert!(super.args, line_no, :(@label $(Symbol("_STATE_",:($n)))))
        insert!(super.args, line_no, arg.args[2])
        insert!(super.args, line_no, :(_fsm._state = $n))
      else
        n = transformYield!(arg, n, super, line_no)
      end
    end
  end
  n
end

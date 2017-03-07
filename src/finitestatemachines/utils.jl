function getArguments(expr) :: Vector{Symbol}
  args = Symbol[]
  kws = Symbol[]
  params = Symbol[]
  if expr.args[1].head == :call
    expr_args = expr.args[1].args
  else
    expr_args = expr.args[1].args[1].args
  end
  for arg in expr_args
    if isa(arg, Symbol)
      push!(args, arg)
    elseif arg.head == Symbol("::")
      push!(args, arg.args[1])
    elseif arg.head == :kw
      if isa(arg.args[1], Symbol)
        push!(kws, arg.args[1])
      else
        push!(kws, arg.args[1].args[1])
      end
    elseif arg.head == :parameters
      for arg2 in arg.args
        if isa(arg2.args[1], Symbol)
          push!(params, arg2.args[1])
        else
          push!(params, arg2.args[1].args[1])
        end
      end
    end
  end
  [args; kws; params]
end

function getSlots(expr::Expr, name::Symbol) :: Dict{Symbol, Type}
  slots = Dict{Symbol, Type}()
  eval(expr)
  code_data_infos = @eval code_typed($name)
  for (code_info, data_type) in code_data_infos
    for i in 2:length(code_info.slotnames)
      slots[code_info.slotnames[i]] = code_info.slottypes[i]
    end
  end
  delete!(slots, Symbol("#temp#"))
  delete!(slots, Symbol("#unused#"))
  slots
end

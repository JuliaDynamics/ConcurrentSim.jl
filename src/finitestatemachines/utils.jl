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

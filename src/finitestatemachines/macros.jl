macro yield(val)
  :($(esc(val)))
end

abstract type FiniteStateMachine end

iscoroutinedone(fsm::FiniteStateMachine) = fsm._state == 0xff

macro stateful(expr::Expr)
  expr.head != :function && error("Expression is not a function definition!")
  args = getArguments(expr)
  func_name = shift!(args)
  type_name = gensym()
  slots = getSlots(expr, func_name)
  type_expr = :(
    mutable struct $type_name <: FiniteStateMachine
      _state :: UInt8
      $((:($slotname :: $(slottype == Union{} ? Any : :($slottype))) for (slotname, slottype) in slots)...)
      function $type_name($((:($arg::$(slots[:($arg)])) for arg in args)...))
        fsm = new()
        fsm._state = 0x00
        $((:(fsm.$arg = $arg) for arg in args)...)
        fsm
      end
    end
  )
  new_expr = deepcopy(expr.args[2])
  transformVars!(new_expr, keys(slots))
  n = transformYield!(new_expr)
  func_expr = :(
    function (_fsm::$type_name)(_ret::Any=nothing)
      _fsm._state == 0x00 && @goto _STATE_0
      $((:(_fsm._state == $i && @goto $(Symbol("_STATE_",:($i)))) for i in 0x01:n)...)
      error("Iterator has stopped!")
      @label _STATE_0
      _fsm._state = 0xff
      $((:($arg) for arg in new_expr.args)...)
    end
  )
  if expr.args[1].head == Symbol("::")
    func_expr.args[1] = Expr(Symbol("::"), func_expr.args[1], expr.args[1].args[2])
  end
  call_expr = deepcopy(expr)
  if call_expr.args[1].head == Symbol("::")
    call_expr.args[1] = call_expr.args[1].args[1]
  end
  call_expr.head = Symbol("=")
  call_expr.args[2] = :($type_name($((:($arg) for arg in args)...)))
  esc(quote
    $type_expr
    $func_expr
    $call_expr
  end)
end

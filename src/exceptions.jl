"""
  `EventNotIdle <: Exception`

Exception thrown when an event is scheduled ([`schedule`](@ref)) that has already been scheduled or is being processed.

Only used internally.
"""

type EventNotIdle <: Exception end

"""
  `EventProcessing <: Exception`

Exception thrown:

- when a callback is added to an event ([`append_callback`](@ref)) that is being processed or
- when an event is scheduled ([`schedule!`](@ref)) that is being processed.

Only used internally.
"""
type EventProcessed <: Exception end

"""
  `StopSimulation <: Exception`

Exception that stops the simulation. A return value can be set.

**Fields**:

- `value :: Any`

**Constructor**:

`StopSimulation(value::Any=nothing)`
"""
type StopSimulation <: Exception
  value :: Any
  function StopSimulation(value::Any=nothing)
    new(value)
  end
end

type InterruptException <: Exception
  cause :: Any
  function InterruptException(cause::Any)
    inter = new()
    inter.cause = cause
    return inter
  end
end

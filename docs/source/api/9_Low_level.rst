Low Level API
-------------

.. function:: step(env::Environment)

Processes the next event.

.. function:: peek(env::Environment) -> Float64

Returns the next event time.

.. function:: schedule(ev::AbstractEvent, priority::Bool, delay::Float64, value=nothing)

.. function:: schedule(ev::AbstractEvent, priority::Bool, value=nothing)

.. function:: schedule(ev::AbstractEvent, delay::Float64, value=nothing)

.. function:: schedule(ev::AbstractEvent, value=nothing)

Schedules an event with a ``value``, a ``delay`` and ``priority``.

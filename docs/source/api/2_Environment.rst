Environment
-----------


BaseEnvironment
~~~~~~~~~~~~~~~

Base type for event processing environments.

An implementation must at least provide the means to access the current time of the environment (see ``now``), to process events (see ``step`` and ``peek``) and to give a reference to the active process (see ``active_process``).

The class is meant to be subclassed for different execution environments. For example, SimJulia defines a :class:`Environment` for simulations with a virtual time.

.. function:: run(env::BaseEnvironment) -> nothing

Executes the ``step`` function until there are no further events to be processed.

.. function:: run(env::BaseEnvironment, until::Float64) -> nothing

Executes the ``step`` function until the environment’s time reaches `until`.

.. function:: run(env::AbstractEnvironment, until::AbstractEvent) -> value::Any

Executes the ``step`` function until this event has been triggered and will return its `value`.



Environment
~~~~~~~~~~~

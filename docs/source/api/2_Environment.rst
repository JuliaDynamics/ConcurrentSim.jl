Environment
-----------


AbstractEnvironment
~~~~~~~~~~~~~~~~~~~

.. type:: AbstractEnvironment

Parent type for event processing environments.

An implementation must at least provide the means to access the current time of the environment (see ``now``), to process events (see ``step`` and ``peek``) and to give a reference to the active process (see ``active_process``).

The class is meant to be subclassed for different execution environments. For example, SimJulia defines a :class:`Environment` for simulations with a virtual time.

.. function:: run(env::AbstractEnvironment) -> nothing

Executes the ``step`` function until there are no further events to be processed.

.. function:: run(env::AbstractEnvironment, until::Float64) -> nothing

Executes the ``step`` function until the environment’s time reaches `until`.

.. function:: run(env::AbstractEnvironment, until::AbstractEvent) -> value::Any

Executes the ``step`` function until the `until` event has been triggered and will return its `value`.

.. function:: stop_simulation(env::AbstractEnvironment, value=nothing)

Stops the simulation, optionally providing an alternative return value to the ``run`` function.


Environment
~~~~~~~~~~~

.. type:: Environment <: AbstractEnvironment

Execution environment for a simulation. The passing of time is simulated by stepping from event to event.

.. function:: Environment(initial_time::Float64=0.0) -> env::Environment

Constructor of :class:`Environment`. An `initial_time` for the environment can be specified. By default, it starts at ``0.0``.

.. function:: now(env::Environment) -> time::Float64

Returns the current simulation time.

.. function:: active_process(env::Environment) -> proc::Process

Returns the active process. If no process is active throws a :class:`NullException`.



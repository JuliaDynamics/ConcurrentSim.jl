SimJulia
--------

The ``SimJulia`` module aggregates SimJulia’s most used components into a single namespace.

The following tables list all of the available types in this module.


Environment
~~~~~~~~~~~

===========================================================  ====================================================
:func:`Environment(initial_time::Float64=0.0)<Environment>`  Execution environment for an event-based simulation.
===========================================================  ====================================================


Events
~~~~~~

=========================================================================  =========================================================
:class:`AbstractEvent`                                                     Base class for all events.
:func:`Event(env::Environment)<Event>`                                     An event that may happen at some point in time.
:func:`Timeout(env::Environment, delay::Float64, value=nothing)<Timeout>`  An event that gets triggered after a `delay` has passed.
=========================================================================  =========================================================


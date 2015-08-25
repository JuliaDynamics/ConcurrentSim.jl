SimJulia
--------

The ``SimJulia`` module aggregates SimJulia’s most used components into a single namespace.

The following tables list all of the available types in this module.


Environment
~~~~~~~~~~~

============================  =======================================
:class:`AbstractEnvironment`  Base type for an environment.
:class:`Environment`          Execution environment for a simulation.
============================  =======================================


Events
~~~~~~

======================  ========================================================================================
:class:`AbstractEvent`  Base type for all events.
:class:`Event`          An event that may happen at some point in time.
:class:`Timeout`        An event that is triggered after a `delay` has passed.
:class:`AllOf`          An event that is triggered if all of a tuple of events have been successfully triggered.
:class:`AnyOf`          An event that is triggered if any of a tuple of events has been successfully triggered.
:class:`EventOperator`  An event that is triggered if an `eval` functions returns true on a tuple of events.
======================  ========================================================================================


Processes
~~~~~~~~~

=======================  ======================================================================================
:class:`Process`         A model that is implemented by a process function yielding events.
\                        An event that is triggered if the process function returns.
:class:`DelayedProcess`  A process that starts after a `delay`.
:class:`Interruption`    An event that is triggered immediately and that interrupts another process.
:class:`Interrupt`       An event that is triggered with priority and has an :class:`InterruptException` value.
=======================  ======================================================================================


Resources
~~~~~~~~~

==================  =============================================================================================
:class:`Resource`   Resource with a `capacity` of usage slots that can be requested by processes.
:class:`Container`  Resource containing up to a `capacity` of matter which may either be continuous or discrete.
:class:`Store`      Resource with a `capacity` of slots for storing arbitrary objects.
:class:`Put`        An event that is triggered if the `put` action of a resource has been executed.
:class:`Get`        An event that is triggered if the `get` action of a resource has been executed.
:class:`Request`    Synonym for :class:`Put` with a :class:`Resource` argument.
:class:`Release`    Synonym for :class:`Get` with a :class:`Resource` argument.
:class:`Preempted`  A type that contains the `cause` and the `usage time` of a preemption on a :class:`Resource`.
==================  =============================================================================================


Exceptions
~~~~~~~~~~

===========================  =============================================================================
:class:`EmptySchedule`       An exception that is thrown if the scheduler contains no events.
:class:`StopSimulation`      An exception that stops the simulation when it is thrown.
:class:`EventTriggered`      An exception that is thrown if an already triggered event is triggered again.
:class:`EventProcessed`      An exception that is thrown if a `callback` is added to a processed event.
:class:`InterruptException`  An exception that is thrown if an `interrupt` occurs.
===========================  =============================================================================

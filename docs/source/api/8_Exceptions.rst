Exceptions
----------

EmptySchedule
~~~~~~~~~~~~~

.. type:: EmptySchedule <: Exception

An exception that is thrown if the scheduler contains no events. Only used internally.


StopSimulation
~~~~~~~~~~~~~~

.. type:: StopSimulation <: Exception

An exception that stops the simulation when it is thrown.


EventTriggered
~~~~~~~~~~~~~~

.. type:: EventTriggered <: Exception

An exception that is thrown if an already triggered event is triggered again. Only used internally.


EventProcessed
~~~~~~~~~~~~~~

.. type:: EventProcessed <: Exception

An exception that is thrown if a `callback` is added to a processed event. Only used internally.


InterruptException
~~~~~~~~~~~~~~~~~~

.. type:: InterruptException <: Exception

An exception that is thrown if an `interrupt` occurs.

.. function:: cause(inter::InterruptException) -> Any

Returns the cause of the interrupt exception.

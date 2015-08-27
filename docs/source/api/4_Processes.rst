Processes
---------

Process
~~~~~~~

.. type:: Process <: AbstractEvent

A :class:`Process` is an abstraction for an event yielding function, a process function.

The process function can suspend its execution by yielding an :class:`AbstractEvent`. The :class:`Process` will take care of resuming the process function with the value of that event once it has happened. The exception of failed events is also thrown into the process function.

A :class:`Process` itself is an event, too. It is triggered, once the process functions returns or raises an exception. The value of the process is the return value of the process function or the exception, respectively.

.. function:: Process(env::AbstractEnvironment, func::Function, args...) -> Process

.. function:: Process(env::AbstractEnvironment, name::ASCIIString, func::Function, args...) -> Process

Constructs a :class:`Process`. The argument ``func`` is the process function and has the following signature :func:``func(env::AbstractEnvironment, args...) <func>``. If the ``name`` argument is missing, the name of the process is a combination of the name of the process function and the event id of the process. An :class:`Initialize` event is scheduled immediately to start the process function.

.. function:: DelayedProcess(env::AbstractEnvironment, delay::Float64, func::Function, args...) -> Process

Constructs a delayed :class:`Process`. A :class:`Timeout` event is scheduled with the specified ``delay``. The process function is started from a callback of the timeout event.

.. function:: yield(ev::AbstractEvent) -> Any

Passes the control flow back to the simulation. If the yielded event is triggered , the simulation will resume the function after this statement. The return value is the value from the yielded event.

.. function:: is_process_done(proc::Process) -> Bool

Returns ``true`` if the process function returned or an exception was thrown.


Initialize
~~~~~~~~~~

.. type:: Initialize <: AbstractEvent

Start a process function. Only used internally by :class:`Process`.
This event is automatically triggered when it is created.


Interrupt
~~~~~~~~~~~~

.. type:: Interrupt <: AbstractEvent

.. function:: Interrupt(proc::Process, cause::Any=nothing) -> Interruption

Immediately schedules an :class:`Interruption` event with as value an instance of :class:`InterruptException`. The process function of ``proc`` is added to its callbacks. An :class:`Interrupt` event is returned. This event is automatically triggered when it is created.


Interruption
~~~~~~~~~~~~

.. type:: Interruption <: AbstractEvent

Only used internally by :class:`Interrupt`.
This event is automatically triggered with priority when it is created.

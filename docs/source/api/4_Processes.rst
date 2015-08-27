Processes
---------

Process
~~~~~~~

.. type:: Process <: AbstractEvent

A :class:`Process` is an abstraction for an event yielding function, a process function.

The process function can suspend its execution by yielding an :class:`AbstractEvent`. The :class:`Process` will take care of resuming the process function with the value of that event once it has happened. The exception of failed events is also thrown into the process function.

A :class:`Process` itself is an event, too. It is triggered, once the process functions returns or raises an exception. The value of the process is the return value of the process function or the exception, respectively.

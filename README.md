SimJulia
========

Process oriented simulation library written in Julia inspired by the Python library SimPy.

A process is implemented as a type containing a Task (co-routine). The produce function is used to schedule future events having a pointer to the Task object. A heap-based simulation kernel processes the events in order by consuming the related Tasks.

Tests are identical to the examples in the SimPy documentation.

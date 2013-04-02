SimJulia
========

Process oriented simulation library written in Julia inspired by the Python library SimPy.

A process is implemented as a type containing a Task (co-routine). The produce function is used to schedule future events having a pointer to the Task object. A heap-based simulation kernel processes the events in order by consuming the related Tasks.

Tests are identical to the examples in the SimPy documentation.
- example_1.jl: Basic simulation. A Process "message" is defined with an associated Task "go".
- example_2.jl: A Process "custimer is defined and the associated Task "buy" has an extra argument "budget".
- example_3.jl: This simulates a firework with a time fuse.
- example_4.jl: A source creates and activates a series of customers who arrive at regular intervals of 10.0 units of time.
- example_5.jl: A simulation with interrupts. A bus is subject to breakdowns that are modelled as interrupts caused by a Process "breakdown".
- example_6.jl: Asynchronous signalling using wait or queue and fire.
- example_7.jl: waituntil is not yet implemented.
- example_8.jl: The Resource "server" is given two resource units. Six clients arrive in the order specified by the program. They all request a resource unit from the "server" at the same time.
- example_9.jl: Priority requests for a Resource unit are not yet implemented.
- example_10.jl: Preemptive requests for a Resource unit are not yet implemented.
- example_11.jl: Reneging after a timelimit before acquiring a Resource is not yet implemented.
- example_12.jl: Reneging when an event has happened before acquiring a Resource is not yet implemented.
- example_13.jl: A Monitor is used to record the Resource queues. After the simulation, some basic statistics for each queue and their complete time series are displayed.

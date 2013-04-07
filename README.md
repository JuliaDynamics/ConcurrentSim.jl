SimJulia
========

Process oriented simulation library written in Julia inspired by the Python library SimPy.

A process is implemented as a type containing a Task (co-routine). The produce function is used to schedule future events having a pointer to the Task object. A heap-based simulation kernel processes the events in order by consuming the related Tasks.

Tests are identical to the examples in the SimPy documentation.

- example_1.jl: Basic simulation. A Process "message" is defined with an associated Task "go".
- example_2.jl: A Process "customer" is defined and the associated Task "buy" has an extra argument "budget".
- example_3.jl: This simulates a firework with a time fuse.
- example_4.jl: A source creates and activates a series of customers who arrive at regular intervals of 10.0 units of time.
- example_5.jl: A simulation with interrupts. A bus is subject to breakdowns that are modelled as interrupts caused by a Process "breakdown".
- example_6.jl: Asynchronous signalling using wait or queue and fire.
- example_7.jl: waituntil not yet implemented.
- example_8.jl: The Resource "server" is given two resource units. Six clients arrive in the order specified by the program. They all request a resource unit from the "server" at the same time.
- example_9.jl: The Resource "server" is given two resource units. Six clients having a priority arrive in the order specified by the program. They all request a resource unit from the "server" at the same time.
- example_10.jl: Preemptive requests for a Resource unit not yet implemented.
- example_11.jl: Reneging after a timelimit before acquiring a Resource is demonstrated by cars seaching a parking space in a parking lot.
- example_12.jl: Reneging when an event has happened before acquiring a Resource not yet implemented.
- example_13.jl: A Monitor is used to record the Resource queues. After the simulation, some basic statistics for each queue and their complete time series are displayed.
- example_14.jl: A random demand on an inventory is made each day. The inventory (modelled as an object of the Level class) is refilled by 10 units at fixed intervals of 10 days. There are no back-orders. A trace is to be printed out each day and whenever there is a stock-out.
- example_15.jl: A Store is used to model the production and consumption of "widgets". The widgets are distinguished by their weight.
- example_16.jl: Cars arrive randomly at a car wash and add themselves to the "waiting cars" Store. They wait passively for a Signal. There are two "Carwash" washers. These get a car, if one is available, wash it and then send the Signal to reactivate the car.
- example_17.jl: Printing a histogram from a Monitor.
- example_18.jl: A Monitor is used to observe exponential random variates.

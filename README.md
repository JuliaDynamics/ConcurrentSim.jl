SimJulia
========

SimJulia is a process oriented simulation framework written in Julia inspired by the Python library SimPy.

A process is implemented as a type containing a Task (co-routine). The "produce" function is used to schedule future events having a pointer to the Task object. A heap-based simulation kernel processes the events in order by "consuming" the related Tasks.

Following intrinsics are implemented:
- sleep: process is deactivated and can be reactivated by another process
- hold: process is busy for a certain amount of time, during this period an interrupt can force the control back to the process
- wait and queue: a process can wait or queue for some signals to be fired by another process
- waitunil: a process can wait for a general condition (which depend on the state of the simulaton) to be satisfied, this functionality requires interrogative scheduling, while all other synchronization constructs are imperative 
- request and release: a resource, a discrete congestion point to which processes may have to queue up, can be requested and when it is finished, be released; queue type can be FIFO or priority without and with preemption; reneging, leaving a queue before acquiring a resource is also implemented
- put and get: a level (continuous) and a store (discrete) model congestion points which can produce or consume continuous/discrete "material"; queue type can be FIFO or priority; reneging, leaving a queue before putting or getting is also implemented
- observe: a monitor enables the observation of a single variable of interest and can return a data summary during or at the end of a simulation run

Tests are identical to the examples in the SimPy documentation.

- example_1.jl: Basic simulation. A Process "message" is defined with an associated Task "go".
- example_2.jl: A Process "customer" is defined and the associated Task "buy" has an extra argument "budget".
- example_3.jl: This simulates a firework with a time fuse.
- example_4.jl: A source creates and activates a series of customers who arrive at regular intervals of 10.0 units of time.
- example_5.jl: A simulation with interrupts. A bus is subject to breakdowns that are modelled as interrupts caused by a Process "breakdown".
- example_6.jl: Asynchronous signalling using wait or queue and fire.
- example_7.jl: Example demonstrates the use of waituntil. The function "killed" in the Task "life" defines the condition to be waited for. 
- example_8.jl: The Resource "server" is given two resource units. Six clients arrive in the order specified by the program. They all request a resource unit from the "server" at the same time.
- example_9.jl: The Resource "server" is given two resource units. Six clients having a priority arrive in the order specified by the program. They all request a resource unit from the "server" at the same time.
- example_10.jl: Two client of different priority compete for the same resource unit. Preemption is enabled.
- example_11.jl: Reneging after a timelimit before acquiring a Resource is demonstrated by cars seaching a parking space in a parking lot.
- example_12.jl: Reneging when an event has happened before acquiring a Resource not yet implemented.
- example_13.jl: A Monitor is used to record the Resource queues. After the simulation, some basic statistics for each queue and their complete time series are displayed.
- example_14.jl: A random demand on an inventory is made each day. The inventory (modelled as an object of the Level class) is refilled by 10 units at fixed intervals of 10 days. There are no back-orders. A trace is to be printed out each day and whenever there is a stock-out.
- example_15.jl: A Store is used to model the production and consumption of "widgets". The widgets are distinguished by their weight.
- example_16.jl: Cars arrive randomly at a car wash and add themselves to the "waiting cars" Store. They wait passively for a Signal. There are two "Carwash" washers. These get a car, if one is available, wash it and then send the Signal to reactivate the car.
- example_17.jl: Printing a histogram from a Monitor.
- example_18.jl: A Monitor is used to observe exponential random variates.

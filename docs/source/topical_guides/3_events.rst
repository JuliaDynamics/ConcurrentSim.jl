Events
------

SimJulia includes an extensive set of event constructors for various purposes. This section details the following events:

- basic events that are created by the constructors:

  - :func:`Event(env::BaseEnvironment) <Event>`
  - :func:`Timeout(env::BaseEnvironment, delay::Float64, value=nothing) <Timeout>`

- compound events that are created by the constructors:

  - :func:`Condition(env::BaseEnvironment, eval::Function, events::Vector{BaseEvent}) <Condition>`
  - :func:`AllOf(env::BaseEnvironment, events::Vector{BaseEvent}) <AllOf>`
  - :func:`AnyOf(env::BaseEnvironment, events::Vector{BaseEvent}) <AnyOf>`

- process events that are created by the constructor:

  - :func:`Process(env::BaseEnvironment, func::Function, args...) <Process>`


The resource and container event constructors are discussed in a later section.


Event basics
~~~~~~~~~~~~

SimJulia events are very similar – if not identical — to deferreds, futures or promises. Instances of the type :class:`Event` are used to describe any kind of events. Events can be in one of the following states:

  - *not triggered*: an event may happen
  - *triggered*: is going to happen
  - *processed*: has happened

They traverse these states exactly once in that order. Events are also tightly bound to time and time causes events to advance their state. Initially, events are not triggered and just objects in memory.

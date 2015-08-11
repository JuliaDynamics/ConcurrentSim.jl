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

SimJulia events are very similar – if not identical — to deferreds, futures or promises. Instances of the type :class:`BaseEvent` are used to describe any kind of events. Events can be in one of the following states:

  - *not triggered*: an event may happen
  - *triggered*: is going to happen
  - *processed*: has happened

They traverse these states exactly once in that order. Events are also tightly bound to time and time causes events to advance their state. Initially, events are not triggered and just objects in memory.

If an event gets triggered, it is scheduled at a given time and inserted into SimJulia’s event list. The function :func:`triggered(ev::BaseEvent) <triggered>` returns ``true``. As long as the event is not processed, you can add callbacks to an event. Callbacks are functions that accept a single event as argument and are stored in the callbacks list of that event. An event becomes processed when SimJulia pops it from the event list and calls all of its callbacks. It is now no longer possible to add callbacks. The function :func:`processed(ev::BaseEvent) <processed>` returns at that moment ``true``.

Events also have a value. The value can be set before or when the event is triggered and can be retrieved via the function :func:`value(ev::BaseEvent) <value>` or, within a process, via the return value of the function :func:`yield(ev::BaseEvent) <yield>`.


Adding callbacks to an event
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

“What? Callbacks? I’ve never seen no callbacks!”, you might think if you have worked your way through the tutorial.

That’s on purpose. The most common way to add a callback to an event is yielding it from your process function (:func:`yield(ev::BaseEvent) <yield>`). This will add the function :func:`proc.resume(ev::Event) <proc.resume>` as a callback. That’s how your process gets resumed when it yielded an event.

However, you can add a function to the list of callbacks as long as it accepts an instance of type :class:`Event` as its first argument using the function :func:`append_callback(ev::BaseEvent, callback::Function, args...) <append_callback>`::

  using SimJulia

  function my_callback(event::Event)
    println("Called back from $event")
  end

  env = Environment()
  event = Event(env)
  append_callback(event, my_callback)
  succeed(event)
  run(env)


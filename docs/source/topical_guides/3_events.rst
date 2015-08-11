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

If an event has been processed, all of its callbacks have been called. Adding more callbacks – these would of course never get called because the event has already happened results in the throwing of a :class:`EventProcessed` exception.


Triggering events
~~~~~~~~~~~~~~~~~

When events are triggered, they can either succeed or fail. For example, if an event is to be triggered at the end of a computation and everything works out fine, the event will succeed. If an exceptions occurs during that computation, the event will fail.

To trigger an event and mark it as successful, you can use :func:`succeed(ev::Event, value=nothing) <succeed>`. You can optionally pass a value to it (e.g., the results of a computation).

To trigger an event and mark it as failed, call :func:`fail(ev::Event, exc::Exception) <fail>` and pass an :class:`Exception` instance to it (e.g., the exception you caught during your failed computation).


Example usages for :class:`Event`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The simple mechanics outlined above provide a great flexibility in the way events can be used.

One example for this is that events can be shared. They can be created by a process or outside of the context of a process. They can be passed to other processes and chained::

  using SimJulia

  type School
    class_ends :: Event
    pupil_procs :: Vector{Process}
    bell_proc :: Process
    function School(env::Environment)
      school = new()
      school.class_ends = Event(env)
      school.pupil_procs = Process[Process(env, pupil, school) for i=1:3]
      school.bell_proc = Process(env, bell, school)
      return school
    end
  end

  function bell(env::Environment, school::School)
    for i=1:2
      yield(Timeout(env, 45.0))
      succeed(school.class_ends)
      school.class_ends = Event(env)
      println()
    end
  end

  function pupil(env::Environment, school::School)
    for i=1:2
      print(" \\o/")
      yield(school.class_ends)
    end
  end

  env = Environment()
  school = School(env)
  run(env)


Let time pass by
~~~~~~~~~~~~~~~~

To actually let time pass in a simulation, there is the timeout event. A timeout constructor has three arguments: :func:`Timeout(env::BaseEnvironment, delay::Float64, value=nothing) <Timeout>`. It is triggered automatically and is scheduled at ``now + delay``. Thus, the succeed() and fail() methods cannot be called again and you have to pass the event value to it when you create the timeout.



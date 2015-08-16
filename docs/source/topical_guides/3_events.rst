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


Processes that are created by the constructor :func:`Process(env::BaseEnvironment, func::Function, args...) <Process>` are also discussed. Technically speaking they are not proper events but they can also be yielded as a subtype of :class:`BaseEvent`.

The resource and container event constructors are discussed in a later section.


Event basics
~~~~~~~~~~~~

SimJulia events are very similar – if not identical — to deferreds, futures or promises. Instances of the type :class:`Event` are used to describe any kind of events. Events can be in one of the following states:

  - *not triggered*: an event may happen
  - *triggered*: is going to happen
  - *processing*: is happening
  - *processed*: has happened

They traverse these states exactly once in that order. Events are also tightly bound to time and time causes events to advance their state. Initially, events are not triggered and just objects in memory.

If an event gets triggered, it is scheduled at a given time and inserted into SimJulia’s event list. The function :func:`triggered(ev::Event) <triggered>` returns ``true``. As long as the event is not processed, you can add callbacks to an event. Callbacks are functions that have as first argument an :class:`Event` and are stored in the callbacks list of that event. An event becomes processed when SimJulia has popped it from the event list and has called all of its callbacks. It is no longer possible to add callbacks. The function :func:`processed(ev::Event) <processed>` returns at that moment ``true``.

Events also have a value. The value can be set before or when the event is triggered and can be retrieved via the function :func:`value(ev::Event) <value>` or, within a process, via the return value of the function :func:`yield(ev::BaseEvent) <yield>`.


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

If an event has been processed, all of its callbacks have been called. Adding more callbacks – these would of course never get called because the event has already happened - results in the throwing of a :class:`EventProcessed` exception.

Processes are smart about this, though. If you yield a processed event, your process will immediately resume with the value of the event (because there is nothing to wait for).


Triggering events
~~~~~~~~~~~~~~~~~

When events are triggered, they can either succeed or fail. For example, if an event is to be triggered at the end of a computation and everything works out fine, the event will succeed. If an exceptions occurs during that computation, the event will fail.

To trigger an event and mark it as successful, you can use :func:`succeed(ev::Event, value=nothing) <succeed>`. You can optionally pass a value to it (e.g., the results of a computation).

To trigger an event and mark it as failed, call :func:`fail(ev::Event, exc::Exception) <fail>` and pass an :class:`Exception` instance to it (e.g., the exception you caught during your failed computation).

There is also a generic way to trigger an event: :func:`trigger(ev::Event, cause::BaseEvent) <trigger>`. This will take the value and outcome (success or failure) of the event passed to it.

All three methods return the event instance they are bound to. This allows you to do things like::

  yield succeed(Event(env))

Triggering an event that was already triggered before results in the throwing of a :class:`EventTriggered` exception.


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

To actually let time pass in a simulation, there is the timeout event. A timeout constructor has three arguments: :func:`Timeout(env::BaseEnvironment, delay::Float64, value=nothing) <Timeout>`. It is triggered automatically and is scheduled at ``now + delay``. Thus, the :func:`succeed(ev::Event, value=nothing) <succeed>`, :func:`fail(ev::Event, exc::Exception) <fail>` and :func:`trigger(ev::Event, cause::BaseEvent) <trigger>` functions cannot be called again and you have to pass the event value to it when you create the timeout event.


Processes are events, too
~~~~~~~~~~~~~~~~~~~~~~~~~

SimJulia processes (as created by the constructor :func:`Process(env::BaseEnvironment, func::Function, args...) <Process>`) have the nice property of being a subtype of :class:`BaseEvent`, too.

That means, that a process can yield another process. It will then be resumed when the other process ends. The event’s value will be the return value of that process::

  using SimJulia

  function sub(env::Environment)
    yield(Timeout(env, 1.0))
    return 23
  end

  function parent(env::Environment)
    return ret = yield(Process(env, sub))
  end

  env = Environment()
  ret = run(env, Process(env, parent))
  println(ret)

When a process is created, it schedules an event which will start the execution of the process when triggered. You usually won’t have to deal with this type of event.

If you don’t want a process to start immediately but after a certain delay, you can use :func:`DelayedProcess(env::BaseEnvironment, delay::Float64, func::Function, args...) <DelayedProcess>`. This method returns a helper process that uses a timeout before actually starting the process.

The example from above, but with a delayed start of ``sub(env::Environment)``::

  using SimJulia

  function sub(env::Environment)
    yield(Timeout(env, 1.0))
    return 23
  end

  function parent(env::Environment)
    start = now(env)
    sub_proc = yield(DelayedProcess(env, 3.0, sub))
    @assert(now(env) - start == 3.0)
    ret = yield(sub_proc)
  end

  env = Environment()
  ret = run(env, Process(env, parent))
  println(ret)


The state of the :class:`Process` can be queried with the function :func:`done(proc::Process) <done>` that returns ``true`` when the process function has returned.


Waiting for multiple events at once
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sometimes, you want to wait for more than one event at the same time. For example, you may want to wait for a resource, but not for an unlimited amount of time. Or you may want to wait until all a set of events has happened.

SimJulia therefore offers the event constructors :func:`AnyOf(env::BaseEnvironment, events::Vector{BaseEvent}) <AnyOf>` and :func:`AllOf(env::BaseEnvironment, events::Vector{BaseEvent}) <AllOf>`. Both take a list of events as an argument and are triggered if at least one or all of them of them are triggered. There is a specific constructors for the more general :func:`Condition(env::BaseEnvironment, eval::Function, events::Vector{BaseEvent}) <Condition>`. The function :func:`eval(events::Vector{Event})` takes one argument a :class:`Vector{Event}` and returns true when the condition is fulfilled.

As a shorthand for :func:`AllOf(env::BaseEnvironment, events::Vector{BaseEvent}) <AllOf>` and :func:`AnyOf(env::BaseEnvironment, events::Vector{BaseEvent}) <AnyOf>`, you can also use the logical operators ``&`` (and) and ``|`` (or)::

  using SimJulia
  using Compat

  function test_condition(env::Environment)
    t1, t2 = Timeout(env, 1.0, "spam"), Timeout(env, 2.0, "eggs")
    ret = yield(t1 | t2)
    @assert(ret == @compat Dict(t1=>"spam"))
    t1, t2 = Timeout(env, 1.0, "spam"), Timeout(env, 2.0, "eggs")
    ret = yield(t1 & t2)
    @assert(ret == @compat Dict(t1=>"spam", t2=>"eggs"))
    e1, e2, e3 = Timeout(env, 1.0, "spam"), Timeout(env, 2.0, "eggs"), Timeout(env, 3.0, "eggs")
    yield((e1 | e2) & e3)
    @assert(all(map((ev)->processed(ev), [e1, e2, e3])))
  end

  env = Environment()
  Process(env, test_condition)
  run(env)


The result of the ``yield`` of a multiple events is of type :class:`Dict` with as keys the processed (processing) events and as values their values. This allows the following idiom for conveniently fetching the values of multiple events specified in an and condition (including :func:`AllOf(env::BaseEnvironment, events::Vector{BaseEvent}) <AllOf>`)::

  using SimJulia
  using Compat

  function fetch_values_of_multiple_events(env::Environment)
    t1, t2 = Timeout(env, 1.0, "spam"), Timeout(env, 2.0, "eggs")
    ret = yield(t1 & t2)
    @assert(ret == @compat Dict(t1=>"spam", t2=>"eggs"))
  end

  env = Environment()
  Process(env, fetch_values_of_multiple_events)
  run(env)


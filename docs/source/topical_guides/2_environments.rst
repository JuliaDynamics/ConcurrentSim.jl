Environments
------------

A simulation environment manages the simulation time as well as the scheduling and processing of events. It also provides means to step through or execute the simulation.

The base type for all environments is :class:`BaseEnvironment`. “Normal” simulations usually use its subtype :class:`Environment`.


Simulation control
~~~~~~~~~~~~~~~~~~

SimJulia is very flexible in terms of simulation execution. You can run your simulation until there are no more events, until a certain simulation time is reached, or until a certain event is triggered. You can also step through the simulation event by event. Furthermore, you can mix these things as you like.

For example, you could run your simulation until an interesting event occurs. You could then step through the simulation event by event for a while; and finally run the simulation until there are no more events left and your processes have all terminated.

The most important method here is :func:`run()`:
If you call it without any argument, it steps through the simulation until there are no more events left. If your processes run forever::

  while true
    yield Timeout(env, 1.0)
  end

this method will never terminate unless you kill your script by pressing Ctrl-C.

In most cases it is advisable to stop your simulation when it reaches a certain simulation time. Therefore, you can pass the desired time via the until parameter::

  run(env, 10.0)

The simulation will then stop when the internal clock reaches ``10.0`` but will not process any events scheduled for time ``10.0``. This is similar to a new environment where the clock is ``0.0`` but (obviously) no events have yet been processed.

Instead of passing a number to :func:`run()`, you can also pass any instance of a :class:`BaseEvent` to it. The function returns when this event has been processed. Assuming that the current time is ``0.0`, :func:`run(env, Timeout(env, 5.0)) <run>` is equivalent to :func:`run(env, 5.0) <run>`. You can also pass other types of events (remember, that :class:`Process` is a subtype of :class:`BaseEvent`)::

  using SimJulia

  function my_proc(env::Environment)
    yield(Timeout(env, 1.0))
    return "Monty Python's Flying Circus"
  end

  env = Environment()
  proc = Process(env, my_proc)
  println(run(env, proc))

To step through the simulation event by event, the environment offers :func:`peek(env::Enivronment) <peek>` and :func:`step(env::Enivronment) <step>`:

- :func:`peek(env::Enivronment) <peek>` returns the time of the next scheduled event or ``Inf`` when no more events are scheduled.
- :func:`step(env::Enivronment) <step>` processes the next scheduled event. It raises an :class:`EmptySchedule` exception if no event is available.

In a typical use case, you use these methods in a loop like:

SimJulia basics
---------------

This guide describes the basic concepts of SimJulia: How does it work? What are processes, events and the environment? What can I do with them?


How SimJulia works
~~~~~~~~~~~~~~~~~~

If you break SimJulia down, it is just an asynchronous event dispatcher, very similar to SimPy. You generate events and schedule them at a given simulation time. Events are sorted by priority, simulation time, and an increasing event id. An event also has a list of callbacks, which are executed when the event is triggered and processed by the event loop. Events may also have a return value.

The components involved in this are the :class:`Environment`, :class:`Events` and the process functions that you write.

Process functions implement your simulation model, that is, they define the behavior of your simulation. They are plain Julia functions that have at least an environment as argument and are wrapped into a :class:`Task`. A task is a control flow feature that allows computations to be suspended and resumed. A process function can so be interrupted by switching to another task. The original task can later be resumed, at which point it will pick up right where it left off. Julia provides the functions :func:`produce()` and :func:`consume()` to implement this functionality. (These functions are however not used directly in SimJulia)

A call of the SimJulia function :func:`yield(ev::Event) <yield>` suspends the process function until the event is triggered and processed. The environment stores the event in its event list and a resume function is added to the event’s callbacks. The environment selects the next event from its event list and keeps track of the current simulation time. The callbacks from this event are called in the same order as they were added. In case the callback is a resume function the associated task is resumed and its process function continues at the point where it left off.

Here is a very simple example that illustrates this all; the code is more verbose than it needs to be to make things extra clear. You find a compact version of it at the end of this section::

  using SimJulia

  function example(env::Environment)
    ev = Timeout(env, 1.0, 42)
    value = yield(ev)
    time = now(env)
    println("now=$time, value=$value")
  end

  env = Environment()
  p = Process(env, example)
  run(env )

The :func:`example(env::Environment) <example>` process function above first creates a timeout event with the constructor :func:`Timeout(env::Environment, delay::Float64, value::Any) <Timeout>`. It passes the environment, a delay, and a value. This event is automatically schedulled at now + delay (that’s why the environment is required); other events usually schedule themselves at the current simulation time.

The process function then yields the timeout event and thus gets suspended. It is resumed, when SimJulia processes the event. The process function also receives the event’s value (`42`) – this is however optional.

Finally, the process function prints the current simulation time that is accessible via the function :func:`now(env::Environment) <now>` and the value of the event.

Once all process functions are defined, you can instantiate the objects for your simulation. In most cases, you start by creating an instance of :class:`Environment`, because you’ll need to pass it around a lot when creating everything else.

You have to call the constructor :func:`Process(env::Environment, func::Function, args...) <Process>` to wrap the process function into the :class:`Task`. This will not execute any code of the process function yet but will schedule an event at the current simulation time which starts the execution of the process function. An instance of the :class:`Process can also be yielded and is triggered when its process function returns.

Finally, you start SimJulia’s event loop by calling :func:`run(env) <run>`. By default, it will run as long as there are events in the event list, but you can also let it stop earlier by providing an until argument :func:`run(env:: Environment, until::Float64) <run>` or :func:`run(env, ev::Event) <run>`.

“Best practice” version of the example above::

  using SimJulia

  function example(env::Environment)
    value = yield(Timeout(env, 1.0, 42))
    println("now=$(now(env)), value=$value")
  end

  env = Environment()
  p = Process(env, example)
  run(env )


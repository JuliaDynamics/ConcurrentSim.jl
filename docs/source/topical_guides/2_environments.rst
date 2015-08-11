Environments
------------

A simulation environment manages the simulation time as well as the scheduling and processing of events. It also provides means to step through or execute the simulation.

The base type for all environments is :class:`BaseEnvironment`. “Normal” simulations usually use its subtype :class:`Environment`.


Simulation control
~~~~~~~~~~~~~~~~~~

SimJulia is very flexible in terms of simulation execution. You can run your simulation until there are no more events, until a certain simulation time is reached, or until a certain event is triggered. You can also step through the simulation event by event. Furthermore, you can mix these things as you like. For example, you could run your simulation until an interesting event occurs. You could then step through the simulation event by event for a while; and finally run the simulation until there are no more events left and your processes have all terminated.

The most important method in this section is :func:`run()`:

- If you call it with only one argument :func:`run(env::Environment) <run>`, it steps through the simulation until there are no more events left.

.. warning::
   If your process function runs forever, e.g.

   .. code-block:: julia

      while true
        yield Timeout(env, 1.0)
      end

   :func:`run(env) <run>` will never terminate unless you kill your script by pressing Ctrl-C.

- In most cases it is advisable to stop your simulation when it reaches a certain simulation time. Therefore, you can pass the desired time via a second argument: :func:`run(env, 10.0) <run>`. The simulation will then stop when the internal clock reaches ``10.0`` but will not process any events scheduled for time ``10.0``. This is similar to a new environment where the clock is ``0.0`` but (obviously) no events have yet been processed.

- Instead of passing a floating point value as second argument, you can also pass any instance of a :class:`BaseEvent` to it. The function returns when this event has been processed. Assuming that the current time is ``0.0``, :func:`run(env, Timeout(env, 5.0)) <run>` is equivalent to :func:`run(env, 5.0) <run>`. You can also pass other types of events (remember, that :class:`Process` is a subtype of :class:`BaseEvent`).

  .. code-block:: julia

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

In a typical use case, you use these methods in a loop like::

  until = 10.0
  while peek(env) < until
    step(env)
  end


State access
~~~~~~~~~~~~

The environment allows you to get the current simulation time via the function :func:`now(env::Environment) <now>`. The simulation time is a floating point value without unit and is increased via timeout events.

By default, the constructor :func:`Environment()` starts the simulation time at ``0.0``, but you can pass an initial value, :func:`Environment(initial_value::Float64) <Environment>` to use something else.

The function :func:`active_process(env::Environment) <active_process>` is comparable to :func:`Base.getpid()` and returns the currently active :class:`Process`. A process is *active* when its process function is being executed. It becomes *inactive* (or suspended) when it yields an event.

Thus, it only makes sense to call this function from within a process function or a function that is called by your process function, otherwise, a :class:`NullException` is thrown::

  using SimJulia

  function subfunc(env::Environment)
    println("Active process: $(active_process(env))")
  end

  function my_proc(env::Environment)
    println("Active process: $(active_process(env))")
    yield(Timeout(env, 1.0))
    subfunc(env)
  end

  env = Environment()
  Process(env, my_proc)
  println("Time: $(peek(env))")
  try
    println(active_process(env))
  catch exc
    println("No active process")
  end
  step(env)
  println("Time: $(peek(env))")
  try
    println(active_process(env))
  catch exc
    println("No active process")
  end
  step(env)
  println("Time: $(peek(env))")
  step(env)
  println("Time: $(peek(env))")

A nice example of this function can be found in the resource system. When a process function calls the constructor :func:`Request(res::Resource) <Request>` to generate a request event for a resource, the resource determines the requesting process via :func:`active_process(env) <active_process>`.


Event creation
~~~~~~~~~~~~~~

To create events, you normally have to use the constructor :func:`Event(env::BaseEnvironment) <Event>` to instantiate
the :class:`Event` type and pass a reference to the environment to it.

Other event constructors are:

- :func:`Timeout(env::BaseEnvironment, delay::Float64, value=nothing) <Timeout>`
- :func:`Condition(env::BaseEnvironment, eval::Function, events::Vector{BaseEvent}) <Condition>`
- :func:`AllOf(env::BaseEnvironment, events::Vector{BaseEvent}) <AllOf>`
- :func:`AnyOf(env::BaseEnvironment, events::Vector{BaseEvent}) <AnyOf>`
- :func:`Request(res::Resource, priority::Int64=0, preempt::Bool=false) <Request>`
- :func:`Release(res::Resource) <Release>`
- :func:`Put{T}(cont::Container, amount::T, priority::Int64=0) <Put>`
- :func:`Get{T}(cont::Container, amount::T, priority::Int64=0) <Get>`
- :func:`Process(env::BaseEnvironment, func::Function, args...) <Process>`

Technically, a :class:`Process` is not an :class:`Event` but it is a subtype of :class:`BaseEvent` having a field of type :class:`Event`.

More details on what events do can be found in the next sections.


Miscellaneous
~~~~~~~~~~~~~

A process function can have a return value::

  using SimJulia

  function my_proc(env::Environment)
    yield(Timeout(env, 1.0))
    return 42
  end

  function other_proc(env::Environment)
    ret_val = yield(Process(env, my_proc))
    @assert(ret_val == 42)
  end

  env = Environment()
  Process(env, other_proc)
  run(env)

The simulation can be stopped by throwing a :class:`StopSimulation` exception in a process function. To keep your code more readable, the function :func:`exit(env::BaseEnvironment) <exit>` does exactly this.

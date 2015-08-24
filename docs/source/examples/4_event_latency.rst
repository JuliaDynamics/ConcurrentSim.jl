Event Latency
-------------

Covers:

  Resources: Store

Scenario:

  This example shows how to separate the time delay of events between processes from the processes themselves.

When Useful:

  When modeling physical things such as cables, RF propagation, etc. it better encapsulation to keep this propagation mechanism outside of the sending and receiving processes.

Can also be used to interconnect processes sending messages.

.. code-block:: julia

  using SimJulia

  const SIM_DURATION = 100.0

  type Cable
    env :: Environment
    delay :: Float64
    store :: Store{ASCIIString}
    function Cable(env::Environment, delay::Float64)
      cable = new()
      cable.env = env
      cable.delay = delay
      cable.store = Store{ASCIIString}(env)
      return cable
    end
  end

  function latency(env::Environment, cable::Cable, value::ASCIIString)
    yield(Timeout(env, cable.delay))
    yield(Put(cable.store, value))
  end

  function put(cable::Cable, value::ASCIIString)
    Process(cable.env, latency, cable, value)
  end

  function get(cable::Cable)
    return yield(Get(cable.store))
  end

  function sender(env::Environment, cable::Cable)
    while true
      yield(Timeout(env, 5.0))
      put(cable, "Sender send this at $(now(env))")
    end
  end

  function receiver(env::Environment, cable::Cable)
    while true
      msg = get(cable)
      println("Received this at $(now(env)) while $msg")
    end
  end

  println("Event latency")
  env = Environment()

  cable = Cable(env, 10.0)
  Process(env, sender, cable)
  Process(env, receiver, cable)

  run(env, SIM_DURATION)

The simulation’s output::

  Event latency
  Received this at 15.0 while Sender send this at 5.0
  Received this at 20.0 while Sender send this at 10.0
  Received this at 25.0 while Sender send this at 15.0
  Received this at 30.0 while Sender send this at 20.0
  Received this at 35.0 while Sender send this at 25.0
  Received this at 40.0 while Sender send this at 30.0
  Received this at 45.0 while Sender send this at 35.0
  Received this at 50.0 while Sender send this at 40.0
  Received this at 55.0 while Sender send this at 45.0
  Received this at 60.0 while Sender send this at 50.0
  Received this at 65.0 while Sender send this at 55.0
  Received this at 70.0 while Sender send this at 60.0
  Received this at 75.0 while Sender send this at 65.0
  Received this at 80.0 while Sender send this at 70.0
  Received this at 85.0 while Sender send this at 75.0
  Received this at 90.0 while Sender send this at 80.0
  Received this at 95.0 while Sender send this at 85.0

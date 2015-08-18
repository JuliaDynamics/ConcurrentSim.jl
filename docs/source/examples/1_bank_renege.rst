Bank Renege
-----------

Covers:

- Resources
- Event operators

A counter with a random service time and customers who renege.

This example models a bank counter and customers arriving at random times. Each customer has a certain patience. It waits to get to the counter until she’s at the end of her tether. If she gets to the counter, she uses it for a while before releasing it.

New customers are created by the source process every few time steps.

.. code-block:: julia

  using SimJulia
  using Distributions

  const RANDOM_SEED = 150
  const NEW_CUSTOMERS = 5  # Total number of customers
  const INTERVAL_CUSTOMERS = 10.0  # Generate new customers roughly every x seconds
  const MIN_PATIENCE = 1.0  # Min. customer patience
  const MAX_PATIENCE = 3.0  # Max. customer patience

  function source(env::BaseEnvironment, number::Int64, interval::Float64, counter::Resource)
    d = Exponential(interval)
    for i in 1:number
      Process(env, customer, "Customer$i", counter, 12.0)
      yield(Timeout(env, rand(d)))
    end
  end

  function customer(env::BaseEnvironment, name::ASCIIString, counter::Resource, time_in_bank::Float64)
    arrive = now(env)
    println("$arrive $name: Here I am")
    req = Request(counter)
    patience = rand(Uniform(MIN_PATIENCE, MAX_PATIENCE))
    result = yield(req | Timeout(env, patience))
    wait = now(env) - arrive
    if in(req, keys(result))
      println("$(now(env)) $name: Waited $wait")
      yield(Timeout(env, rand(Exponential(time_in_bank))))
      println("$(now(env)) $name: Finished")
      yield(Release(counter))
    else
      println("$(now(env)) $name: RENEGED after $wait")
      cancel(counter, req)
    end
  end

  # Setup and start the simulation
  println("Bank renege")
  srand(RANDOM_SEED)
  env = Environment()

  # Start processes and run
  counter = Resource(env, 1)
  Process(env, source, NEW_CUSTOMERS, INTERVAL_CUSTOMERS, counter)
  run(env)

The simulation’s output::

  Bank renege
  0.0 Customer1: Here I am
  0.0 Customer1: Waited 0.0
  4.435484832567573 Customer1: Finished
  21.013085103081753 Customer2: Here I am
  21.013085103081753 Customer2: Waited 0.0
  23.097746900916643 Customer3: Here I am
  23.91170855317896 Customer2: Finished
  23.91170855317896 Customer3: Waited 0.8139616522623179
  30.113622311091923 Customer4: Here I am
  30.621135918022613 Customer5: Here I am
  32.43509581615485 Customer5: RENEGED after 1.8139598981322358
  32.63868913452709 Customer3: Finished
  32.63868913452709 Customer4: Waited 2.525066823435168
  35.25594434892944 Customer4: Finished

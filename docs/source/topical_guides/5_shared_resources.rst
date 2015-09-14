Shared Resources
----------------

Shared resources are another way to model process interaction. They form a congestion point where processes queue up in order to use them.

SimJulia defines three categories of resources:

  - :class:`Resource`: Resources that can be used by a limited number of processes at a time (e.g., a gas station with a limited number of fuel pumps).
  - :class:`Container`: Resources that model the production and consumption of a homogeneous, undifferentiated bulk. It may either be continuous (like water) or discrete (like apples).
  - :class:`Store`: Resources that allow the production and consumption of Julia types.

.. note::
   All resources are implemented using only the exported functions of SimJulia and are showcases of the functionalities of the previous chapters.

The basic concept of resources
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

All resources share the same basic concept: The resource itself is some kind of a container with a, usually limited, capacity. Processes can either try to put something into the resource or try to get something out. If the resource is full or empty, they have to queue up and wait.

Every resources has maximum capacity and two queues, one for processes that want to put something into it and one for processes that want to get something out. The :func:`Put` and :func:`Get` constructors both return an event that is triggered when the corresponding action was successful.


Resources and interrupts
~~~~~~~~~~~~~~~~~~~~~~~~

While a process is waiting for a resource, it may be interrupted by another process. After catching the interrupt, the process has two possibilities:

  - It may continue to wait for the request (by yielding the event again).
  - It may stop waiting for the request (by calling the :func:`cancel`).

The resource system is modular and extensible. Resources can, for example, use specialized queues. This allows them to add priorities to events or to offer preemption.


Resources
~~~~~~~~~

Resources can be used by a limited number of processes at a time (e.g., a gas station with a limited number of fuel pumps). Processes request these resources to become a user (or to “own” them) and have to release them once they are done (e.g., vehicles arrive at the gas station, use a fuel-pump, if one is available, and leave when they are done).

Requesting a resources is modeled as “putting a process’ token into the resources” and releasing a resources correspondingly as “getting a process’ token out of the resource”. Releasing a resource will always succeed immediately. Requesting and releasing a resource is done by yielding a request / release event. The request event has the following constructor :func:`Request(res::Resource, priority::Int64=0, preempt::Bool=false) <Request>` and the release event :func:`Release(res::Resource) <Release>`.

The :class:`Resource` is conceptually a semaphore. The only argument of its constructor – apart from the obligatory reference to an Environment – is its capacity. It must be a positive number and defaults to 1: :func:`Resource(env::AbstractEnvironment, capacity::Int=1) <Resource>`.

Instead of just counting its current users, it stores the requesting process as an “access token” for each user. This is, for example, useful for adding preemption (see further).

Here is as basic example for using a resource::

  using SimJulia

  function print_stats(res::Resource)
    println("$(count(res)) of $(capacity(res)) are allocated.")
  end

  function resource_user(env::Environment, res::Resource)
    print_stats(res)
    yield(Request(res))
    print_stats(res)
    yield(Release(res))
    print_stats(res)
  end

  env = Environment()
  res = Resource(env, 1)
  Process(env, resource_user, res)
  Process(env, resource_user, res)
  run(env)

The functions :func:`count(res::Resource) <count>` and :func:`capacity(res::Resource) <capacity>` return respectively the number of processes using the resource and the capacity of the resource.


Priority resource
~~~~~~~~~~~~~~~~~

As you may know from the real world, not every one is equally important. To map that to SimJulia, the constructor :func:`Request(res::Resource, priority::Int64=0, preempt::Bool=false) <Request>` lets requesting processes provide a priority for each request. More important requests will gain access to the resource earlier than less important ones. Priority is expressed by integer numbers; smaller numbers mean a higher priority::

  using SimJulia

  function resource_user(env::Environment, name::Int, res::Resource, wait::Float64, prio::Int)
    yield(Timeout(env, wait))
    println("$name Requesting at $(now(env)) with priority=$prio")
    yield(Request(res, prio))
    println("$name got resource at $(now(env))")
    yield(Timeout(env, 3.0))
    yield(Release(res))
  end

  env = Environment()
  res = Resource(env, 1)
  p1 = Process(env, resource_user, 1, res, 0.0, 0)
  p2 = Process(env, resource_user, 2, res, 1.0, 0)
  p3 = Process(env, resource_user, 3, res, 2.0, -1)
  run(env)

Although ``p3`` requested the resource later than ``p2``, it could use it earlier because its priority was higher.


Preemptive resource
~~~~~~~~~~~~~~~~~~~

Sometimes, new requests are so important that queue-jumping is not enough and they need to kick existing users out of the resource (this is called preemption). As before the constructor :func:`Request(res::Resource, priority::Int64=0, preempt::Bool=false) <Request>` allows you to do exactly this::

  using SimJulia

  function resource_user(env::Environment, name::Int, res::Resource, wait::Float64, prio::Int)
    yield(Timeout(env, wait))
    println("$name Requesting at $(now(env)) with priority=$prio")
    yield(Request(res, prio, true))
    println("$name got resource at $(now(env))")
    try
      yield(Timeout(env, 3.0))
      yield(Release(res))
    catch exc
      pre = cause(exc)
      usage = now(env) - usage_since(pre)
      println("$name got preempted by $(by(pre)) at $(now(env)) after $usage")
    end
  end

  env = Environment()
  res = Resource(env, 1)
  p1 = Process(env, resource_user, 1, res, 0.0, 0)
  p2 = Process(env, resource_user, 2, res, 1.0, 0)
  p3 = Process(env, resource_user, 3, res, 2.0, -1)
  run(env)


An :class:`InterruptException` is generated. Its cause is of type :class:`Preempted`, so that the functions :func:`by(pre::Preempted) <by>` and :func:`usage_since(pre::Preempted) <usage_since>` return respectively the preempting process and the duration that the preempted process has hold the resource.

The implementation values priorities higher than preemption. That means preempt request are not allowed to cheat and jump over a higher prioritized request. The following example shows that preemptive low priority requests cannot queue-jump over high priority requests::

  using SimJulia

  function user(env::Environment, name::ASCIIString, res::Resource, wait::Float64, prio::Int, preempt::Bool)
    println("$name Requesting at $(now(env))")
    yield(Request(res, prio, preempt))
    println("$name got resource at $(now(env))")
    try
      yield(Timeout(env, 3.0))
      yield(Release(res))
    catch exc
      println("$name got preempted at $(now(env))")
    end
  end

  env = Environment()
  res = Resource(env, 1)
  A = Process(env, user, "A", res, 0.0, 0, true)
  run(env, 1.0)
  B = Process(env, user, "B", res, 1.0, -2, false)
  C = Process(env, user, "C", res, 2.0, -1, true)
  run(env)

- Process ``A`` requests the resource with priority ``0``. It immediately becomes a user.
- Process ``B`` requests the resource with priority ``-2`` but sets preempt to ``false``. It will queue up and wait.
- Process ``C`` requests the resource with priority ``-1`` but sets preempt to ``true``. Normally, it would preempt ``A`` but in this case, ``B`` is queued up before ``C`` and prevents ``C`` from preempting ``A``. ``C`` can also not preempt ``B`` since its priority is not high enough.

Thus, the behavior in the example is the same as if no preemption was used at all. Be careful when using mixed preemption! Due to the higher priority of process ``B``, no preemption occurs in this example. Note that an additional request with a priority of ``-3`` would be able to preempt ``A``.


Containers
~~~~~~~~~~

Containers help you modelling the production and consumption of a homogeneous, undifferentiated bulk. It may either be continuous (like water) or discrete (like apples).

You can use this, for example, to model the gas / petrol tank of a gas station. Tankers increase the amount of gasoline in the tank while cars decrease it.

The following example is a very simple model of a gas station with a limited number of fuel dispensers (modeled as :class:``Resource``) and a tank modeled as :class:``Container``::

  using SimJulia

  type GasStation
    fuel_dispensers :: Resource
    gas_tank :: Container{Float64}
    function GasStation(env::Environment)
      gs = new()
      gs.fuel_dispensers = Resource(env, 2)
      gs.gas_tank = Container{Float64}(env, 1000.0, 100.0)
      Process(env, monitor_tank, gs)
      return gs
    end
  end

  function monitor_tank(env::Environment, gs::GasStation)
    while true
      if level(gs.gas_tank) < 100.0
        println("Calling tanker at $(now(env))")
        Process(env, tanker, gs)
      end
      yield(Timeout(env, 15.0))
    end
  end

  function tanker(env::Environment, gs::GasStation)
    yield(Timeout(env, 10.0))
    println("Tanker arriving at $(now(env))")
    amount = capacity(gs.gas_tank) - level(gs.gas_tank)
    yield(Put(gs.gas_tank, amount))
  end

  function car(env::Environment, name::Int, gs::GasStation)
    println("Car $name arriving at $(now(env))")
    yield(Request(gs.fuel_dispensers))
    println("Car $name starts refueling at $(now(env))")
    yield(Get(gs.gas_tank, 40.0))
    yield(Timeout(env, 15.0))
    yield(Release(gs.fuel_dispensers))
    println("Car $name done refueling at $(now(env))")
  end

  function car_generator(env::Environment, gs::GasStation)
    for i = 0:3
      Process(env, car, i, gs)
      yield(Timeout(env, 5.0))
    end
  end

  env = Environment()
  gs = GasStation(env)
  Process(env, car_generator, gs)
  run(env, 55.0)

The constructors :func:`Put(cont::Container, amount::T, priority::Int64=0) <Put>` and :func:`Get(cont::Container, amount::T, priority::Int64=0) <Get>` create respectively events to put and to get an amount of fuel. The function :func:`level(cont::Container) <level>` returns the amount of fuel still in the tank.

Priorities can be given to a put or a get event by setting the argument ``priority``.


Stores
~~~~~~

Using a :class:`Store` you can model the production and consumption of concrete objects (in contrast to the rather abstract “amount” stored in a :class:`Container`). A single :class:`Store` can even contain multiple types of objects.

A custom function can also be used to filter the objects you get out of the store.

Here is a simple example modelling a generic producer/consumer scenario::

  using SimJulia

  function producer(env::Environment, sto::Store)
    for i = 1:100
      yield(Timeout(env, 2.0))
      yield(Put(sto, "spam $i"))
      println("Produced spam at $(now(env))")
    end
  end

  function consumer(env::Environment, name::Int64, sto::Store)
    while true
      yield(Timeout(env, 1.0))
      println("$name requesting spam at $(now(env))")
      item = yield(Get(sto))
      println("$name got $item at $(now(env))")
    end
  end

  env = Environment()
  sto = Store{ASCIIString}(env, 2)

  prod = Process(env, producer, sto)
  consumers = [Process(env, consumer, i, sto) for i=1:2]

  run(env, 5.0)


As with the other resource types, you can get a store’s capacity via the function :func:`capacity(sto::Store) <capacity>`. The function :func:`items(sto::Store) <items>` returns a :class:`Set` of items currently available in the store.

A store with a filter on the :class:`Get` event can, for example, be used to model machine shops where machines have varying attributes. This can be useful if the homogeneous slots of a :class:`Resource` are not what you need::

  using SimJulia

  type Machine
    size :: Int64
    duration :: Float64
  end

  function user(env::Environment, name::Int64, sto::Store, size::Int64)
    machine = yield(Get(sto, (mach::Machine)->mach.size == size))
    println("$name got $machine at $(now(env))")
    yield(Timeout(env, machine.duration))
    yield(Put(sto, machine))
    println("$name released $machine at $(now(env))")
  end

  function machineshop(env::Environment, sto::Store)
    m1 = Machine(1, 2.0)
    m2 = Machine(2, 1.0)
    yield(Put(sto, m1))
    yield(Put(sto, m2))
  end

  env = Environment()
  sto = Store{Machine}(env, 2)
  ms = Process(env, machineshop, sto)
  users = [Process(env, user, i, sto, (i % 2) +1) for i=0:2]
  run(env)



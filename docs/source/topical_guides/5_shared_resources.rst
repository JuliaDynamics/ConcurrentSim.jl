Shared Resources
----------------

Shared resources are another way to model process interaction. They form a congestion point where processes queue up in order to use them.

SimJulia defines two categories of resources:

  - :class:`Resource`: Resources that can be used by a limited number of processes at a time (e.g., a gas station with a limited number of fuel pumps).
  - :class:`Container`: Resources that model the production and consumption of a homogeneous, undifferentiated bulk. It may either be continuous (like water) or discrete (like apples).


The basic concept of resources
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

All resources share the same basic concept: The resource itself is some kind of a container with a, usually limited, capacity. Processes can either try to put something into the resource or try to get something out. If the resource is full or empty, they have to queue up and wait.

While a process is waiting for a resource, it may be interrupted by another process. After catching the interrupt, the process has two possibilities:

  - It may continue to wait for the request (by yielding the request event again).
  - It may stop waiting for the request (by yielding a release event).

The resource system is modular and extensible. Resources can, for example, use specialized queues. This allows them to add priorities to events or to offer preemption.


Resources
~~~~~~~~~

Resources can be used by a limited number of processes at a time (e.g., a gas station with a limited number of fuel pumps). Processes request these resources to become a user (or to “own” them) and have to release them once they are done (e.g., vehicles arrive at the gas station, use a fuel-pump, if one is available, and leave when they are done).

Requesting a resources is modeled as “putting a process’ token into the resources” and releasing a resources correspondingly as “getting a process’ token out of the resource”. Releasing a resource will always succeed immediately. Requesting and releasing a resource is done by yielding a request / release event. The request event has the following constructor :func:`Request(res::Resource, priority::Int64=0, preempt::Bool=false) <Request>` and the release event :func:`Release(res::Resource) <Release>`.

The :class:`Resource` is conceptually a semaphore. The only argument of its constructor – apart from the obligatory reference to an Environment – is its capacity. It must be a positive number and defaults to 1: :func:`Resource(env::BaseEnvironment, capacity::Int=1) <Resource>`.

Instead of just counting its current users, it stores the request event as an “access token” for each user. This is, for example, useful for adding preemption (see further).

Here is as basic example for using a resource::

  using SimJulia

  function print_stats(res::Resource)
    println("$(count(res)) of $(capacity(res)) are allocated.")
    println("  Users: $(res.user_list)")
    println("  Queued processes: $(res.queue)")
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


Repair Problem
--------------

Covers:

  - Resources: :class:`Resource`
  - Resources: :class:`Store`
  - Interrupts

A system needs ``n`` working machines to be operational. To guard against machine breakdown, additional machines are kept available as spares. Whenever a machine breaks down it is immediately replaced by a spare and is itself sent to the repair facility, which consists of a single repairperson who repairs failed machines one at a time. Once a failed machine has been repaired it becomes available as a spare to be used when the need arises. All repair times are independent random variables having a common exponential distribution function. Each time a machine is put into use the amount of time it functions before breaking down is a random variable, independent of the past, having an exponential distribution function.

The system is said to “crash” when a machine fails and no spares are available. Assuming that there are initially ``n + s`` functional machines of which n are put in use and s are kept as spares, we are interested in simulating this system so as to approximate ``E[T]``, where ``T`` is the time at which the system crashes.

.. code-block:: julia

  using SimJulia
  using Distributions

  const RUNS = 100
  const N = 10
  const S = 3
  const SEED = 150
  const LAMBDA = 100
  const MU = 1

  function work(env::Environment, repair_facility::Resource, spares::Store{Process})
    dist_work = Exponential(LAMBDA)
    dist_repair = Exponential(MU)
    while true
      try
        yield(Timeout(env, Inf))
      catch(exc)
      end
      println("At time $(now(env)): $(active_process(env)) starts working.")
      yield(Timeout(env, rand(dist_work)))
      println("At time $(now(env)): $(active_process(env)) stops working.")
      get_spare = Get(spares)
      res = yield(get_spare | Timeout(env, 0.0))
      if in(get_spare, keys(res))
        yield(Interrupt(res[get_spare]))
      else
        stop_simulation(env)
      end
      yield(Request(repair_facility))
      println("At time $(now(env)): $(active_process(env)) repair starts.")
      yield(Timeout(env, rand(dist_repair)))
      yield(Release(repair_facility))
      println("At time $(now(env)): $(active_process(env)) is repaired.")
      yield(Put(spares, active_process(env)))
    end
  end

  function start_sim(env::Environment, repair_facility::Resource, spares::Store{Process})
    procs = Process[]
    for i=1:N
      push!(procs, Process(env, "Machine $i", work, repair_facility, spares))
    end
    yield(Timeout(env, 0.0))
    for proc in procs
      yield(Interrupt(proc))
    end
    for i=1:S
      yield(Put(spares, Process(env, "Machine $(i+10)", work, repair_facility, spares)))
    end
  end

  function sim_repair()
    env = Environment()
    repair_facility = Resource(env)
    spares = Store{Process}(env)
    Process(env, start_sim, repair_facility, spares)
    run(env)
    now(env)
  end

  srand(SEED)
  results = Float64[]
  for i=1:RUNS
    push!(results, sim_repair())
  end
  println(sum(results)/RUNS)

The simulation’s output::

  ...
  At time 10746.862481297383: Machine 9 starts working.
  At time 10746.862481297383: Machine 7 repair starts.
  At time 10748.673383437574: Machine 7 is repaired.
  At time 10760.598516359223: Machine 10 stops working.
  At time 10760.598516359223: Machine 7 starts working.
  At time 10760.598516359223: Machine 10 repair starts.
  At time 10761.127926380934: Machine 10 is repaired.
  At time 10763.742027509461: Machine 1 stops working.
  At time 10763.742027509461: Machine 10 starts working.
  At time 10763.742027509461: Machine 1 repair starts.
  At time 10763.940397277867: Machine 12 stops working.
  At time 10763.940397277867: Machine 2 starts working.
  At time 10764.498080704856: Machine 4 stops working.
  At time 10764.498080704856: Machine 6 starts working.
  At time 10764.703085034163: Machine 6 stops working.
  11685.41156141544

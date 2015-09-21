Process Communication
---------------------

Covers:

  Resources: Store

This example shows how to interconnect simulation model elements together using a :class:`Store` for one-to-one, and many-to-one asynchronous processes. For one-to-many a simple type :class:`BroadCastPipe` is constructed from :class:`Store`.

When Useful:

  - When a consumer process does not always wait on a generating process and these processes run asynchronously. This example shows how to create a buffer and also tell is the consumer process was late yielding to the event from a generating process.

  - This is also useful when some information needs to be broadcast to many receiving processes

  - Finally, using pipes can simplify how processes are interconnected to each other in a simulation model.

.. code-block:: julia

  using SimJulia
  using Distributions

  const RANDOM_SEED = 17102015
  const SIM_TIME = 100.0

  type Message
    timestamp :: Float64
    txt :: ASCIIString
  end

  type BroadcastPipe{T}
    env :: Environment
    capacity :: Int
    pipes :: Vector{Store{T}}
    function BroadcastPipe(env::Environment, capacity::Int=typemax(Int))
      bc_pipe = new()
      bc_pipe.env = env
      bc_pipe.capacity = capacity
      bc_pipe.pipes = Store{T}[]
      return bc_pipe
    end
  end

  function put{T}(bc_pipe::BroadcastPipe{T}, value::T)
    return AllOf(ntuple((i)->Put(bc_pipe.pipes[i], value), length(bc_pipe.pipes))...)
  end

  function get_output_conn{T}(bc_pipe::BroadcastPipe{T})
    pipe = Store{T}(bc_pipe.env, bc_pipe.capacity)
    push!(bc_pipe.pipes, pipe)
    return pipe
  end

  function message_generator(env::Environment, out_pipe::BroadcastPipe{Message})
    d = Uniform(6.0, 10.0)
    while true
      yield(Timeout(env, rand(d)))
      msg = Message(now(env), "$(active_process(env)) says hello at time $(round(now(env), 2))")
      yield(put(out_pipe, msg))
    end
  end

  function message_consumer(env::Environment, in_pipe::Store{Message})
    d = Uniform(4.0, 8.0)
    while true
      msg = yield(Get(in_pipe))
      if msg.timestamp < now(env)
        println("LATE getting message at time $(round(now(env), 2)): $(active_process(env)) received message: $(msg.txt)")
      else
        println("At time $(round(now(env), 2)): $(active_process(env)) received message: $(msg.txt)")
      end
      yield(Timeout(env, rand(d)))
    end
  end

  # Setup and start the simulation
  println("Process communication")
  srand(RANDOM_SEED)

  env = Environment()
  bc_pipe = BroadcastPipe{Message}(env)
  Process(env, "Generator A", message_generator, bc_pipe)
  Process(env, "Consumer A", message_consumer, get_output_conn(bc_pipe))
  Process(env, "Consumer B", message_consumer, get_output_conn(bc_pipe))

  run(env, SIM_TIME)

The simulation’s output::

  Process communication
  At time 8.42: Consumer A received message: Generator A says hello at time 8.42
  At time 8.42: Consumer B received message: Generator A says hello at time 8.42
  At time 17.02: Consumer A received message: Generator A says hello at time 17.02
  At time 17.02: Consumer B received message: Generator A says hello at time 17.02
  At time 23.17: Consumer B received message: Generator A says hello at time 23.17
  LATE getting message at time 24.57: Consumer A received message: Generator A says hello at time 23.17
  At time 29.62: Consumer B received message: Generator A says hello at time 29.62
  LATE getting message at time 30.9: Consumer A received message: Generator A says hello at time 29.62
  At time 37.04: Consumer B received message: Generator A says hello at time 37.04
  LATE getting message at time 38.02: Consumer A received message: Generator A says hello at time 37.04
  LATE getting message at time 44.55: Consumer B received message: Generator A says hello at time 43.24
  LATE getting message at time 45.4: Consumer A received message: Generator A says hello at time 43.24
  LATE getting message at time 50.78: Consumer B received message: Generator A says hello at time 50.63
  LATE getting message at time 52.25: Consumer A received message: Generator A says hello at time 50.63
  LATE getting message at time 57.61: Consumer B received message: Generator A says hello at time 57.47
  LATE getting message at time 58.51: Consumer A received message: Generator A says hello at time 57.47
  At time 64.82: Consumer B received message: Generator A says hello at time 64.82
  LATE getting message at time 65.0: Consumer A received message: Generator A says hello at time 64.82
  At time 71.76: Consumer A received message: Generator A says hello at time 71.76
  LATE getting message at time 72.64: Consumer B received message: Generator A says hello at time 71.76
  At time 81.03: Consumer A received message: Generator A says hello at time 81.03
  At time 81.03: Consumer B received message: Generator A says hello at time 81.03
  At time 89.32: Consumer A received message: Generator A says hello at time 89.32
  At time 89.32: Consumer B received message: Generator A says hello at time 89.32
  At time 96.33: Consumer A received message: Generator A says hello at time 96.33
  LATE getting message at time 96.36: Consumer B received message: Generator A says hello at time 96.33

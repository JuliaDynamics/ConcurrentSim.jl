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
  capacity :: Int64
  pipes :: Vector{Store{T}}
  function BroadcastPipe(env::Environment, capacity::Int64)
    bc_pipe = new()
    bc_pipe.env = env
    bc_pipe.capacity = capacity
    bc_pipe.pipes = Vector{Store{T}}()
    return bc_pipe
  end
end

function BroadcastPipe{T}(env::Environment, ::Type{T}, capacity::Int64=typemax(Int64))
  return BroadcastPipe{T}(env, capacity)
end

function put{T}(bc_pipe::BroadcastPipe{T}, value::T)
  return AllOf(ntuple((i)->Put(bc_pipe.pipes[i], value), length(bc_pipe.pipes))...)
end

function get_output_conn{T}(bc_pipe::BroadcastPipe{T})
  pipe = Store(bc_pipe.env, T, bc_pipe.capacity)
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
bc_pipe = BroadcastPipe(env, Message)
Process(env, "Generator A", message_generator, bc_pipe)
Process(env, "Consumer A", message_consumer, get_output_conn(bc_pipe))
Process(env, "Consumer B", message_consumer, get_output_conn(bc_pipe))

run(env, SIM_TIME)

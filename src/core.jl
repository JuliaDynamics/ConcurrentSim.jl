using Base.Collections

type EventID
  time :: Float64
  priority :: Bool
  id :: Uint16
end

type Event
  callbacks :: Set
  ev_id :: EventID
  value
  function Event()
    ev = new()
    ev.callbacks = Set{Function}()
    return ev
  end
end

typealias Timeout Event

type Process
  name :: ASCIIString
  task :: Task
  target :: Event
  ev :: Event
  execute :: Function
  function Process(name::ASCIIString, task::Task)
    proc = new()
    proc.name = name
    proc.task = task
    return proc
  end
end

type Condition
  check :: Function
  ev :: Event
  function Condition(check::Function)
    cond = new()
    cond.check = check
    cond.ev = Event()
  end
end

type Environment
  now :: Float64
  heap :: PriorityQueue{Event, EventID}
  eid :: Uint16
  active_proc :: Process
  function Environment(initial_time::Float64=0.0)
    env = new()
    env.now = initial_time
    if VERSION >= v"0.4-"
      env.heap = PriorityQueue(Event, EventID)
    else
      env.heap = PriorityQueue{Event, EventID}()
    end
    env.eid = 0
    return env
  end
end

type EmptySchedule <: Exception end
type EventProcessed <: Exception end

type Interrupt <: Exception
  cause :: Process
  msg :: ASCIIString
  function Interrupt(cause::Process, msg::ASCIIString="")
    inter = new()
    inter.cause = cause
    inter.msg = msg
    return inter
  end
end

function Timeout(env::Environment, delay::Float64)
  ev = Event()
  schedule(env, ev, delay)
  return ev
end

function Process(env::Environment, name::ASCIIString, func::Function, args...)
  proc = Process(name, Task(()->func(env, args...)))
  proc.ev = Event()
  proc.execute = (env, ev)->execute(env, ev, proc)
  ev = Event()
  push!(ev.callbacks, proc.execute)
  schedule(env, ev, true)
  proc.target = ev
  return proc
end

function show(io::IO, ev::Event)
  print(io, "Event $(ev.ev_id.id)")
end

function show(io::IO, proc::Process)
  print(io, "Process $(proc.name)")
end

function show(io::IO, inter::Interrupt)
  print(io, "Interrupt caused by $(inter.cause): $(inter.msg)")
end

function now(env::Environment)
  return env.now
end

function add(ev::Event, callback::Function)
  push!(ev.callbacks, callback)
end

function value(ev::Event)
  return ev.value
end

function active_process(env::Environment)
  return env.active_proc
end

function cause(inter::Interrupt)
  return inter.cause
end

function isless(a::EventID, b::EventID)
	return (a.time < b.time) || (a.time == b.time && a.priority > b.priority) || (a.time == b.time && a.priority == b.priority && a.id < b.id)
end

function triggered(ev::Event)
  return isdefined(ev, :value)
end

function processed(ev::Event)
  return isdefined(ev, :value) && isa(ev.callbacks, Set{Nothing})
end

function schedule(env::Environment, ev::Event, priority::Bool, delay::Float64, value=nothing)
  env.eid += 1
  ev.ev_id = EventID(env.now + delay, priority, env.eid)
  env.heap[ev] = ev.ev_id
  ev.value = value
  return ev
end

function schedule(env::Environment, ev::Event, priority::Bool, value=nothing)
  schedule(env, ev, priority, 0.0, value)
end

function schedule(env::Environment, ev::Event, delay::Float64, value=nothing)
  schedule(env, ev, false, delay, value)
end

function schedule(env::Environment, ev::Event, value=nothing)
  schedule(env, ev, false, 0.0, value)
end

function succeed(env::Environment, ev::Event, value=nothing)
  schedule(env, ev, value)
end

function fail(env::Environment, ev::Event, exc::Exception)
  schedule(env, ev, exc)
end

function run(env::Environment)
  ev = Event()
  run(env, ev)
end

function run(env::Environment, at::Float64)
  ev = Event()
  schedule(env, ev, at)
  run(env, ev)
end

function run(env::Environment, until::Event)
  push!(until.callbacks, stop_simulate)
  try
    while true
      step(env)
    end
  catch exc
    if !isa(exc, EmptySchedule)
      rethrow(exc)
    end
  end
end

function step(env::Environment)
  if isempty(env.heap)
    throw(EmptySchedule())
  end
  ev = dequeue!(env.heap)
  env.now = ev.ev_id.time
  while !isempty(ev.callbacks)
    callback = pop!(ev.callbacks)
    callback(env, ev)
  end
  ev.callbacks = Set{Nothing}()
end

function stop_simulate(env::Environment, ev::Event)
  throw(EmptySchedule())
end

function execute(env::Environment, ev::Event, proc::Process)
  env.active_proc = proc
  try
    value = consume(proc.task, ev.value)
    if istaskdone(proc.task)
      schedule(env, proc.ev, value)
    end
  catch exc
    if !isempty(proc.ev.callbacks)
      schedule(env, proc.ev, exc)
    else
      rethrow(exc)
    end
  end
end

function yield(env::Environment, ev::Event)
  if processed(ev)
    throw(EventProcessed())
  end
  env.active_proc.target = ev
  push!(ev.callbacks, env.active_proc.execute)
  value = produce(ev)
  if isa(value, Exception)
    throw(value)
  end
  return value
end

function yield(env::Environment, delay::Float64)
  ev = Timeout(env, delay)
  return yield(env, ev)
end

function yield(env::Environment, proc::Process)
  return yield(env, proc.ev)
end

function yield(env:Environment, cond::Condition)
  return yield(env, cond.ev)
end

function interrupt(env::Environment, proc::Process, msg::ASCIIString="")
  if !istaskdone(proc.task) && proc!=env.active_proc
    ev = Event()
    push!(ev.callbacks, proc.execute)
    schedule(env, ev, true, Interrupt(env.active_proc, msg))
    delete!(proc.target.callbacks, proc.execute)
  end
end

function check_and()

end

function and(ev1::Event, ev2::Event)
  cond = Condition()

  return cond
end

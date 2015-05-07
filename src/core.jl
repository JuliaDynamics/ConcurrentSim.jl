using Base.Collections

type EventKey
  time :: Float64
  priority :: Bool
  id :: Uint16
end

const EVENT_TRIGGERED = 1
const EVENT_PROCESSED = 2

type Event
  callbacks :: Set{Function}
  id :: Uint16
  value :: Any
  state :: Uint16
  function Event()
    ev = new()
    ev.callbacks = Set{Function}()
    ev.state = 0
    return ev
  end
end

typealias Timeout Event

type Process
  task :: Task
  target :: Event
  ev :: Event
  execute :: Function
  function Process(task::Task)
    proc = new()
    proc.task = task
    return proc
  end
end

type Condition
  evaluate :: Function
  events :: Vector{Event}
  ev :: Event
  function Condition(evaluate::Function, events::Vector{Event})
    cond = new()
    cond.evaluate = evaluate
    cond.events = events
    cond.ev = Event()
    return cond
  end
end

type Environment
  now :: Float64
  heap :: PriorityQueue{Event, EventKey}
  eid :: Uint16
  active_proc :: Process
  function Environment(initial_time::Float64=0.0)
    env = new()
    env.now = initial_time
    if VERSION >= v"0.4-"
      env.heap = PriorityQueue(Event, EventKey)
    else
      env.heap = PriorityQueue{Event, EventKey}()
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

function Process(env::Environment, func::Function, args...)
  proc = Process(Task(()->func(env, args...)))
  proc.ev = Event()
  proc.execute = (ev)->execute(env, ev, proc)
  ev = Event()
  push!(ev.callbacks, proc.execute)
  schedule(env, ev, true)
  proc.target = ev
  return proc
end

function Condition(env::Environment, evaluate::Function, events::Vector{Event})
  cond = Condition(evaluate, events)
  if isempty(events)
    succeed(env, cond.ev, condition_values(events))
  end
  for ev in events
    if processed(ev)
      check(cond, ev)
    else
      append_callback(env, ev, check, cond)
    end
  end
  return cond
end

function show(io::IO, ev::Event)
  print(io, "Event $(ev.id)")
end

function show(io::IO, proc::Process)
  print(io, "Process $(proc.task)")
end

function show(io::IO, inter::Interrupt)
  print(io, "Interrupt caused by $(inter.cause): $(inter.msg)")
end

function now(env::Environment)
  return env.now
end

function append_callback(env::Environment, ev::Event, callback::Function, args...)
  push!(ev.callbacks, (event)->callback(env, event, args...))
end

function value(ev::Event)
  return ev.value
end

function cause(inter::Interrupt)
  return inter.cause
end

function isless(a::EventKey, b::EventKey)
	return (a.time < b.time) || (a.time == b.time && a.priority > b.priority) || (a.time == b.time && a.priority == b.priority && a.id < b.id)
end

function triggered(ev::Event)
  return ev.state == EVENT_TRIGGERED
end

function processed(ev::Event)
  return ev.state == EVENT_PROCESSED
end

function schedule(env::Environment, ev::Event, priority::Bool, delay::Float64, value=nothing)
  env.eid += 1
  env.heap[ev] = EventKey(env.now + delay, priority, env.eid)
  ev.id = env.eid
  ev.value = value
  ev.state = EVENT_TRIGGERED
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
  append_callback(env, until, stop_simulate)
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
  (ev, key) = peek(env.heap)
  dequeue!(env.heap)
  env.now = key.time
  while !isempty(ev.callbacks)
    callback = pop!(ev.callbacks)
    callback(ev)
  end
  ev.state = EVENT_PROCESSED
  ev.callbacks = Set{Function}()
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

function yield(env::Environment, cond::Condition)
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

function condition_values(events::Vector{Event})
  values = Dict{Event, Any}()
  for ev in events
    if processed(ev)
      values[ev] = ev.value
    end
  end
end

function check(env::Environment, ev::Event, cond::Condition)
  if !triggered(cond.ev) && !processed(cond.ev)
    if isa(ev.value, Exception)
      fail(env, cond.ev, ev.value)
    elseif cond.evaluate(cond.events)
      succeed(env, cond.ev, condition_values(cond.events))
    end
  end
end

function evaluate_and(events::Vector{Event})
  return all(map((ev)->triggered(ev), events))
end

function and(env, ev1::Event, ev2::Event)
  cond = SimJulia.Condition(env, evaluate_and, [ev1, ev2])
  return cond
end

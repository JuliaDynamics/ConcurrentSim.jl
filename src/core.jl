using Base.Collections

const EVENT_TRIGGERED = 1
const EVENT_PROCESSED = 2

abstract BaseEvent
abstract BaseEnvironment

type EventKey
  time :: Float64
  priority :: Bool
  id :: Uint16
end

function isless(a::EventKey, b::EventKey)
	return (a.time < b.time) || (a.time == b.time && a.priority > b.priority) || (a.time == b.time && a.priority == b.priority && a.id < b.id)
end

type Event <: BaseEvent
  env :: BaseEnvironment
  callbacks :: Set{Function}
  state :: Uint16
  id :: Uint16
  value :: Any
  function Event(env::BaseEnvironment)
    ev = new()
    ev.env = env
    ev.callbacks = Set{Function}()
    ev.state = 0
    ev.id = 0
    return ev
  end
end

typealias Timeout Event
typealias Interrupt Event
typealias Condition Event

type Process <: BaseEvent
  env :: BaseEnvironment
  task :: Task
  target :: BaseEvent
  callbacks :: Set{Function}
  state :: Uint16
  id :: Uint16
  value :: Any
  execute :: Function
  function Process(env::BaseEnvironment, task::Task)
    proc = new()
    proc.env = env
    proc.task = task
    proc.callbacks = Set{Function}()
    proc.state = 0
    proc.id = 0
    return proc
  end
end

type Environment <: BaseEnvironment
  time :: Float64
  sched :: PriorityQueue{BaseEvent, EventKey}
  eid :: Uint16
  active_proc :: Process
  function Environment(initial_time::Float64=0.0)
    env = new()
    env.time = initial_time
    if VERSION >= v"0.4-"
      env.sched = PriorityQueue(BaseEvent, EventKey)
    else
      env.sched = PriorityQueue{BaseEvent, EventKey}()
    end
    env.eid = 0
    return env
  end
end

function Timeout(env::BaseEnvironment, delay::Float64)
  ev = Event(env)
  schedule(ev, delay)
  return ev
end

function Process(env::BaseEnvironment, func::Function, args...)
  proc = Process(env, Task(()->func(env, args...)))
  proc.execute = (ev)->execute(env, ev, proc)
  ev = Event(env)
  push!(ev.callbacks, proc.execute)
  schedule(ev, true)
  proc.target = ev
  return proc
end

function Interrupt(env::BaseEnvironment, proc::Process, msg::ASCIIString="")
  inter = Event(env)
  if !istaskdone(proc.task) && proc!=env.active_proc
    ev = Event(env)
    push!(ev.callbacks, proc.execute)
    schedule(ev, true, InterruptException(env.active_proc, msg))
    delete!(proc.target.callbacks, proc.execute)
  end
  schedule(inter)
  return inter
end

function Condition(env::BaseEnvironment, eval::Function, events::Vector{BaseEvent})
  cond = Event(env)
  if isempty(events)
    succeed(cond, condition_values(events))
  end
  for ev in events
    if processed(ev)
      check(ev, cond, eval, events)
    else
      append_callback(ev, check, cond, eval, events)
    end
  end
  return cond
end

type EmptySchedule <: Exception end
type EventProcessed <: Exception end
type InterruptException <: Exception
  cause :: Process
  msg :: ASCIIString
  function InterruptException(cause::Process, msg::ASCIIString)
    inter = new()
    inter.cause = cause
    inter.msg = msg
    return inter
  end
end

function show(io::IO, ev::Event)
  print(io, "Event id $(ev.id)")
end

function show(io::IO, proc::Process)
  print(io, "Process $(proc.task)")
end

function show(io::IO, inter::InterruptException)
  print(io, "Interrupt caused by $(inter.cause): $(inter.msg)")
end

function triggered(ev::BaseEvent)
  return ev.state == EVENT_TRIGGERED
end

function processed(ev::BaseEvent)
  return ev.state == EVENT_PROCESSED
end

function now(env::BaseEnvironment)
  return env.time
end

function value(ev::BaseEvent)
  return ev.value
end

function cause(inter::InterruptException)
  return inter.cause
end

function schedule(ev::BaseEvent, priority::Bool, delay::Float64, value=nothing)
  ev.env.eid += 1
  ev.id = ev.env.eid
  ev.env.sched[ev] = EventKey(ev.env.time + delay, priority, ev.id)
  ev.value = value
  ev.state = EVENT_TRIGGERED
end

function schedule(ev::BaseEvent, priority::Bool, value=nothing)
  schedule(ev, priority, 0.0, value)
end

function schedule(ev::BaseEvent, delay::Float64, value=nothing)
  schedule(ev, false, delay, value)
end

function schedule(ev::BaseEvent, value=nothing)
  schedule(ev, false, 0.0, value)
end

function condition_values(events::Vector{BaseEvent})
  values = Dict{BaseEvent, Any}()
  for ev in events
    if processed(ev)
      values[ev] = ev.value
    end
  end
end

function append_callback(ev::BaseEvent, callback::Function, args...)
  push!(ev.callbacks, (ev)->callback(ev, args...))
end

function succeed(ev::Event, value=nothing)
  schedule(ev, value)
end

function fail(ev::Event, exc::Exception)
  schedule(ev, exc)
end

function run(env::Environment)
  ev = Event(env)
  run(env, ev)
end

function run(env::BaseEnvironment, at::Float64)
  ev = Event(env)
  schedule(ev, at)
  run(env, ev)
end

function run(env::BaseEnvironment, until::BaseEvent)
  append_callback(until, stop_simulate)
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
  if isempty(env.sched)
    throw(EmptySchedule())
  end
  (ev, key) = peek(env.sched)
  dequeue!(env.sched)
  env.time = key.time
  ev.state = EVENT_PROCESSED
  while !isempty(ev.callbacks)
    callback = pop!(ev.callbacks)
    callback(ev)
  end
end

function stop_simulate(ev::BaseEvent)
  throw(EmptySchedule())
end

function execute(env::BaseEnvironment, ev::BaseEvent, proc::Process)
  env.active_proc = proc
  try
    value = consume(proc.task, ev.value)
    if istaskdone(proc.task)
      schedule(proc, value)
    end
  catch exc
    if !isempty(proc.callbacks)
      schedule(proc, exc)
    else
      rethrow(exc)
    end
  end
end

function yield(ev::BaseEvent)
  if processed(ev)
    throw(EventProcessed())
  end
  ev.env.active_proc.target = ev
  push!(ev.callbacks, ev.env.active_proc.execute)
  value = produce(ev)
  if isa(value, Exception)
    throw(value)
  end
  return value
end

function check(ev::BaseEvent, cond::Condition, eval::Function, events::Vector{BaseEvent})
  if !triggered(cond) && !processed(cond)
    if isa(ev.value, Exception)
      fail(cond, ev.value)
    elseif eval(events)
      succeed(cond, condition_values(events))
    end
  end
end

function eval_and(events::Vector{BaseEvent})
  return all(map((ev)->processed(ev), events))
end

function eval_or(events::Vector{BaseEvent})
  return any(map((ev)->processed(ev), events))
end

function (&)(ev1::BaseEvent, ev2::BaseEvent)
  events = BaseEvent[ev1, ev2]
  return Condition(ev1.env, eval_and, events)
end

function (|)(ev1::BaseEvent, ev2::BaseEvent)
  events = BaseEvent[ev1, ev2]
  return Condition(ev1.env, eval_or, events)
end

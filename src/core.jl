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

type KernelEvent
  env :: BaseEnvironment
  callbacks :: Set{Function}
  state :: Uint16
  id :: Uint16
  value :: Any
  function KernelEvent(env::BaseEnvironment)
    kev = new()
    kev.env = env
    kev.callbacks = Set{Function}()
    kev.state = 0
    kev.id = 0
    return kev
  end
end

type Event :> BaseEvent
  kev :: KernelEvent
  function Event(env::BaseEnvironment)
    ev = new()
    ev.kev = KernelEvent(env)
  end
end

typealias Timeout Event

type Process :> BaseEvent
  task :: Task
  target :: BaseEvent
  kev :: KernelEvent
  execute :: Function
  function Process(env::BaseEnvironment, task::Task)
    proc = new()
    proc.task = task
    proc.kev = KernelEvent(env)
    return proc
  end
end

type Environment :> BaseEnvironment
  now :: Float64
  heap :: PriorityQueue{KernelEvent, EventKey}
  eid :: Uint16
  active_proc :: Process
  function Environment(initial_time::Float64=0.0)
    env = new()
    env.now = initial_time
    if VERSION >= v"0.4-"
      env.heap = PriorityQueue(KernelEvent, EventKey)
    else
      env.heap = PriorityQueue{KernelEvent, EventKey}()
    end
    env.eid = 0
    return env
  end
end

function Timeout(env::BaseEnvironment, delay::Float64)
  ev = Event(env)
  schedule(env, ev, delay)
  return ev
end

function Process(env::BaseEnvironment, func::Function, args...)
  proc = Process(Task(()->func(env, args...)))
  proc.ev = Event(env)
  proc.execute = (ev)->execute(env, ev, proc)
  ev = Event(env)
  push!(ev.callbacks, proc.execute)
  schedule(env, ev, true)
  proc.target = ev
  return proc
end

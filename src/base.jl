using Base.Collections

const EVENT_TRIGGERED = 1
const EVENT_PROCESSED = 2

type EventKey
  time :: Float64
  priority :: Bool
  id :: Uint16
end

type KernelEvent
  callbacks :: Set{Function}
  id :: Uint16
  value :: Any
  state :: Uint16
  function KernelEvent()
    ev = new()
    ev.callbacks = Set{Function}()
    ev.id = 0
    ev.state = 0
    return ev
  end
end

type Scheduler
  heap :: PriorityQueue{BaseEvent, EventKey}
  function Scheduler()
    sched = new()
    if VERSION >= v"0.4-"
      sched.heap = PriorityQueue(Event, EventKey)
    else
      sched.heap = PriorityQueue{Event, EventKey}()
    end
  end
end

"""
  `EVENT_STATE`

Enum with values:

- `idle=0`
- `triggered=1`
- `processing=2`
- `processed=3`
"""
@enum EVENT_STATE idle=0 triggered=1 processing=2 processed=3

"""
  `Event`

An event is a state machine with four states:

- `idle`
- `triggered`
- `processing`
- `processed`

An event is initially not triggered. Events get trigerred after they are scheduled for processing.

An event has a list of callbacks and a value. A callback can be any function. Once an event gets processed, all callbacks will be invoked. Callbacks can do further processing with the value it has produced.

Failed events, i.e. events having as value an `Exception`, are never silently ignored and will raise this exception upon being processed.

**Fields:**

- `cid :: UInt`
- `callbacks :: PriorityQueue{Function, UInt}`
- `state :: EVENT_STATE`
- `value :: Any`

**Constructor:**

`Event()`
"""
type Event
  cid :: UInt
  callbacks :: PriorityQueue{Function, UInt}
  state :: EVENT_STATE
  value :: Any
  function Event()
    ev = new()
    ev.cid = 0x0
    ev.callbacks = PriorityQueue(Function, UInt)
    ev.state = idle
    ev.value = nothing
    return ev
  end
end

type Process
  task :: Task
  target :: Event
  resume :: Function
  ev :: Event
  function Process(task::Task, target::Event)
    proc = new()
    proc.task = task
    proc.target = target
    proc.resume = append_callback(proc.target, execute, proc)
    proc.ev = Event()
    return proc
  end
end

"""
  `EventKey`

Key for the event heap.

**Fields**:

- `time :: Float64`
- `priority :: Bool`
- `id :: UInt`

**Constructor**:

`EventKey(time :: Float64, priority :: Bool, id :: UInt`)

Only used internally.
"""
immutable EventKey
  time :: TimeType
  priority :: Bool
  id :: UInt
end

"""
  `isless(a::EventKey, b::EventKey) :: Bool`

Compairs two `EventKey`. The criteria in order of importance are:

- time of processing
- priority when time of processing is equal
- scheduling id, i.e. the event that was first scheduled is first processed when time of processing and priority are identical

Only used internally.
"""
function isless(a::EventKey, b::EventKey) :: Bool
  (a.time < b.time) || (a.time == b.time && a.priority > b.priority) || (a.time == b.time && a.priority == b.priority && a.id < b.id)
end

"""
  `Simulation{T<:TimeType}`

Execution environment for a simulation. The passing of time is implemented by stepping from event to event.

**Fields**:

- `time :: T`
- `heap :: PriorityQueue{Event, EventKey}`
- `sid :: UInt`
- `active_proc :: Nullable{Process}`
- `granularity` :: Type

**Constructor**:

`Simulation{T<:TimeType}(initial_time::T)`
`Simulation(initial_time::Number=0)`

An initial_time for the simulation can be specified. By default, it starts at 0.
"""
type Simulation{T<:TimeType}
  time :: T
  heap :: PriorityQueue{Event, EventKey}
  sid :: UInt
  active_proc :: Nullable{Process}
  granularity :: Type
  function Simulation(initial_time::T)
    sim = new()
    sim.time = initial_time
    sim.heap = PriorityQueue(Event, EventKey)
    sim.sid = 0x0
    sim.active_proc = Nullable{Process}()
    sim.granularity = typeof(initial_time.instant.periods)
    return sim
  end
end

function Simulation{T<:TimeType}(initial_time::T)
  Simulation{T}(initial_time)
end

function Simulation(initial_time::Number=0)
  Simulation(SimulationTime(initial_time))
end

typealias Put Event
typealias Get Event

type ResourceKey
  priority :: Int
  id :: UInt
  preempt :: Bool
  since :: Period
end

type Resource
  capacity :: UInt
  seid :: Uint
  put_queue :: PriorityQueue{Event, ResourceKey}
  get_queue :: PriorityQueue{Event, ResourceKey}
  users :: PriorityQueue{Process, ResourceKey}
  function Resource(capacity::UInt=0x1)
    res = new()
    res.capacity = capacity
    res.seid = 0x0
    res.put_queue = PriorityQueue(Event, ResourceKey)
    res.get_queue = PriorityQueue(Event, ResourceKey)
    res.users = PriorityQueue(Process, ResourceKey)
    return res
  end
end

function Put(res::Resource; priority::Int=0, preempt::Bool=false)
  req = Event()
  res.put_queue[req] = ResourceKey(priority, res.seid+=1, preempt, 0.0)
  append_callback(req, trigger_get, res)
  trigger_put(sim)
  return req

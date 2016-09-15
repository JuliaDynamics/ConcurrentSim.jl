type ResourceKey
  priority :: Int
  id :: UInt
end

function isless(a::ResourceKey, b::ResourceKey)
  return (a.priority < b.priority) || (a.priority == b.priority && a.id < b.id)
end

type Resource <: AbstractResource
  capacity :: UInt
  users :: UInt
  seid :: UInt
  put_queue :: PriorityQueue{Event, ResourceKey}
  get_queue :: PriorityQueue{Event, ResourceKey}
  function Resource()
    res = new()
    res.capacity = 0x1
    res.users = 0x0
    res.seid = 0x0
    res.put_queue = PriorityQueue(Event, ResourceKey)
    res.get_queue = PriorityQueue(Event, ResourceKey)
    return res
  end
end

request(sim::Simulation, res::Resource; priority::Int=0) = put(sim, res, priority=priority)

function put(sim::Simulation, res::Resource; priority::Int=0) :: Event
  req = Event()
  res.put_queue[req] = ResourceKey(priority, res.seid+=1)
  append_callback(req, trigger_get, res)
  trigger_put(sim, req, res)
  return req
end

function do_put(sim::Simulation, res::Resource, put_ev::Event) :: Bool
  if res.users < res.capacity
    schedule(sim, put_ev)
    res.users += 0x1
    return true
  end
  return false
end

release(sim::Simulation, res::Resource; priority::Int=0) = get(sim, res, priority=priority)

function get(sim::Simulation, res::Resource; priority::Int=0) :: Event
  req = Event()
  res.get_queue[req] = ResourceKey(priority, res.seid+=1)
  append_callback(req, trigger_put, res)
  trigger_get(sim, req, res)
  return req
end

function do_get(sim::Simulation, res::Resource, get_ev::Event) :: Bool
  if res.users > 0x0
    schedule(sim, get_ev)
    res.users -= 0x1
    return true
  end
  return false
end

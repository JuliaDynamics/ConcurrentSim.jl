type ResourceValue
  ev :: Event
  proc :: Process
end

type ResourceKey
  priority :: Int64
  id :: Uint16
end

function isless(a::ResourceKey, b::ResourceKey)
	return (a.priority < b.priority) || (a.priority == b.priority && a.id < b.id)
end

type Resource
  eid :: Uint16
  env :: BaseEnvironment
  capacity :: Int64
  preempt :: Bool
  queue :: PriorityQueue{ResourceValue, ResourceKey}
  user_list :: Dict{Process, ResourceKey}
  function Resource(env::BaseEnvironment, capacity::Int64, preempt::Bool)
    res = new()
    res.eid = 0
    res.env = env
    res.capacity = capacity
    res.preempt = preempt
    if VERSION >= v"0.4-"
      res.queue = PriorityQueue(ResourceValue, ResourceKey)
    else
      res.queue = PriorityQueue{ResourceValue, ResourceKey}()
    end
    res.user_list = Dict{Process, ResourceKey}()
    return res
  end
end

function Resource(env::BaseEnvironment, capacity::Int64=1)
  return Resource(env, capacity, false)
end

function Resource(env::BaseEnvironment, preempt::Bool)
  return Resource(env, 1, preempt)
end

function Request(res::Resource, priority::Int64=0)
  ev = Event(res.env)
  res.eid += 1
  res_key = ResourceKey(priority, res.eid)
  res.queue[ResourceValue(ev, res.env.active_proc)] = res_key
  trigger_put(Event(res.env), res)
  return ev
end

function Release(res::Resource)
  ev = Event(res.env)
  schedule(ev)
  append_callback(ev, (ev)->trigger_put(ev, res))
  trigger_get(Event(res.env), res, res.env.active_proc)
  return ev
end

function trigger_put(ev::Event, res::Resource)
  if length(res.queue) > 0
    (val, key) = peek(res.queue)
    if length(res.user_list) < res.capacity
      res.user_list[val.proc] = key
      succeed(val.ev)
      dequeue!(res.queue)
    end
  end
end

function trigger_get(ev::Event, res::Resource, proc::Process)
  delete!(res.user_list, proc)
end


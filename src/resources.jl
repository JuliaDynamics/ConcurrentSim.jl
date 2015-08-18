type ResourceKey
  priority :: Int64
  id :: Uint16
  preempt :: Bool
  time :: Float64
end

type Preempted
  by :: Process
  usage_since :: Float64
end

type Request <: AbstractEvent
  bev :: BaseEvent
  proc :: Process
  function Request(env::AbstractEnvironment, id::Uint16, priority::Int64, preempt::Bool)
    req = new()
    req.bev = BaseEvent(env)
    req.proc = active_process(env)
    return req
  end
end

type Resource
  env :: Environment
  eid :: Uint16
  capacity :: Int
  queue :: PriorityQueue{Request, ResourceKey}
  user_list :: PriorityQueue{Process, ResourceKey}
  function Resource(env::AbstractEnvironment, capacity::Int=1)
    res = new()
    res.env = env
    res.eid = 0
    res.capacity = capacity
    if VERSION >= v"0.4-"
      res.queue = PriorityQueue(Request, ResourceKey)
      res.user_list = PriorityQueue(Process, ResourceKey, Order.Reverse)
    else
      res.queue = PriorityQueue{Request, ResourceKey}()
      res.user_list = PriorityQueue{Process, ResourceKey}(Order.Reverse)
    end
    return res
  end
end

function Request(res::Resource, id::Uint16, priority::Int64=0, preempt::Bool=false)
  req = Request(res.env, id, priority, preempt)
  res.queue[req] = ResourceKey(priority, id, preempt, 0.0)
  trigger_put(req, res)
  return req
end

function Request(res::Resource, priority::Int64=0, preempt::Bool=false)
  res.eid += 1
  return Request(res, res.eid, priority, preempt)
end

type Release <: AbstractEvent
  bev :: BaseEvent
  function Release(res::Resource)
    rel = new()
    env = res.env
    rel.bev = BaseEvent(env)
    proc = active_process(env)
    append_callback(rel, trigger_put, res)
    dequeue!(res.user_list, proc)
    succeed(rel)
    return rel
  end
end

function isless(a::ResourceKey, b::ResourceKey)
  return (a.priority < b.priority) || (a.priority == b.priority && a.preempt < b.preempt) || (a.priority == b.priority && a.preempt == b.preempt && a.id < b.id)
end

function show(io::IO, pre::Preempted)
  print(io, "preemption by $(pre.by)")
end

function cancel(res::Resource, req::Request)
  dequeue!(res.queue, req)
end

function trigger_put(ev::AbstractEvent, res::Resource)
  while length(res.queue) > 0
    (ev, key) = peek(res.queue)
    proc = ev.proc
    if length(res.user_list) >= res.capacity && key.preempt
      (proc_preempt, key_preempt) = peek(res.user_list)
      if key_preempt > key
        dequeue!(res.user_list)
        Interruption(proc_preempt, Preempted(proc, key_preempt.time))
      end
    end
    if length(res.user_list) < res.capacity
      key.time = now(res.env)
      res.user_list[proc] = key
      succeed(ev, key.id)
      dequeue!(res.queue)
    else
      break
    end
  end
end

function by(pre::Preempted)
  return pre.by
end

function usage_since(pre::Preempted)
  return pre.usage_since
end

function count(res::Resource)
  return length(res.user_list)
end

function capacity(res::Resource)
  return res.capacity
end

type ResourceKey <: AbstractResourceKey
  priority :: Int64
  schedule_time :: Float64
  preempt :: Bool
  since :: Float64
end

type PutResource <: PutEvent
  bev :: BaseEvent
  proc :: Process
  res :: AbstractResource
  function PutResource(env::AbstractEnvironment, res::AbstractResource)
    put = new()
    put.bev = BaseEvent(env)
    put.proc = active_process(env)
    put.res = res
    return put
  end
end

type GetResource <: GetEvent
  bev :: BaseEvent
  proc :: Process
  res :: AbstractResource
  function GetResource(env::AbstractEnvironment, res::AbstractResource)
    get = new()
    get.bev = BaseEvent(env)
    get.proc = active_process(env)
    get.res = res
    return get
  end
end

type Resource <: AbstractResource
  env :: AbstractEnvironment
  capacity :: Int
  put_queue :: PriorityQueue{PutResource, ResourceKey}
  get_queue :: PriorityQueue{GetResource, ResourceKey}
  users :: PriorityQueue{Process, ResourceKey}
  function Resource(env::AbstractEnvironment, capacity=1)
    res = new()
    res.env = env
    res.capacity = capacity
    if VERSION >= v"0.4-"
      res.put_queue = PriorityQueue(PutResource, ResourceKey)
      res.get_queue = PriorityQueue(GetResource, ResourceKey)
      res.users = PriorityQueue(Process, ResourceKey, Order.Reverse)
    else
      res.put_queue = PriorityQueue{PutResource, ResourceKey}()
      res.get_queue = PriorityQueue{GetResource, ResourceKey}()
      res.users = PriorityQueue{Process, ResourceKey}(Order.Reverse)
    end
    return res
  end
end

function Request(res::Resource, key::ResourceKey)
  req = PutResource(res.env, res)
  res.put_queue[req] = key
  append_callback(req, trigger_get, res)
  trigger_put(req, res)
  return req
end

function Request(res::Resource, priority::Int64=0, preempt::Bool=false)
  return Request(res, ResourceKey(priority, now(res.env), preempt, 0.0))
end

function Release(res::Resource)
  rel = GetResource(res.env, res)
  res.get_queue[rel] = ResourceKey(0, now(res.env), false, 0.0)
  append_callback(rel, trigger_put, res)
  trigger_get(rel, res)
  return rel
end

function isless(a::ResourceKey, b::ResourceKey)
  return (a.priority < b.priority) || (a.priority == b.priority && a.preempt < b.preempt) || (a.priority == b.priority && a.preempt == b.preempt && a.schedule_time < b.schedule_time)
end

function show(io::IO, pre::Preempted)
  print(io, "preemption by $(pre.by)")
end

function do_put(res::Resource, ev::PutResource, key::ResourceKey)
  if length(res.users) >= res.capacity && key.preempt
    (proc_preempt, key_preempt) = peek(res.users)
    if key_preempt > key
      dequeue!(res.users)
      Interruption(proc_preempt, Preempted(ev.proc, key_preempt.since))
    end
  end
  if length(res.users) < res.capacity
    key.since = now(res.env)
    res.users[ev.proc] = key
    succeed(ev, key)
  end
end

function do_get(res::Resource, ev::GetResource, key::ResourceKey)
  dequeue!(res.users, ev.proc)
  succeed(ev)
end

function count(res::Resource)
  return length(res.users)
end

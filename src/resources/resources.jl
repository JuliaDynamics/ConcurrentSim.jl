type ResourceKey <: AbstractResourceKey
  priority :: Int64
  schedule_time :: Float64
  preempt :: Bool
  since :: Float64
end

type Request <: PutEvent
  bev :: BaseEvent
  proc :: Process
  res :: AbstractResource
  function Request(env::AbstractEnvironment, res::AbstractResource)
    req = new()
    req.bev = BaseEvent(env)
    req.proc = active_process(env)
    req.res = res
    return req
  end
end

type Release <: GetEvent
  bev :: BaseEvent
  proc :: Process
  res :: AbstractResource
  function Release(env::AbstractEnvironment, res::AbstractResource)
    rel = new()
    rel.bev = BaseEvent(env)
    rel.proc = active_process(env)
    rel.res = res
    return rel
  end
end

type Resource <: AbstractResource
  env :: AbstractEnvironment
  capacity :: Int
  put_queue :: PriorityQueue{Request, ResourceKey}
  get_queue :: PriorityQueue{Release, ResourceKey}
  users :: PriorityQueue{Process, ResourceKey}
  function Resource(env::AbstractEnvironment, capacity=1)
    res = new()
    res.env = env
    res.capacity = capacity
    if VERSION >= v"0.4-"
      res.put_queue = PriorityQueue(Request, ResourceKey)
      res.get_queue = PriorityQueue(Release, ResourceKey)
      res.users = PriorityQueue(Process, ResourceKey, Order.Reverse)
    else
      res.put_queue = PriorityQueue{Request, ResourceKey}()
      res.get_queue = PriorityQueue{Release, ResourceKey}()
      res.users = PriorityQueue{Process, ResourceKey}(Order.Reverse)
    end
    return res
  end
end

function Request(res::Resource, key::ResourceKey)
  req = Request(res.env, res)
  res.put_queue[req] = key
  append_callback(req, trigger_get, res)
  trigger_put(req, res)
  return req
end

function Request(res::Resource, priority::Int64=0, preempt::Bool=false)
  return Request(res, ResourceKey(priority, now(res.env), preempt, 0.0))
end

function Release(res::Resource, priority::Int64=0, preempt::Bool=false)
  rel = Release(res.env, res)
  res.get_queue[rel] = ResourceKey(priority, now(res.env), preempt, 0.0)
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

function do_put(res::Resource, ev::Request, key::ResourceKey)
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

function do_get(res::Resource, ev::Release, key::ResourceKey)
  dequeue!(res.users, ev.proc)
  succeed(ev)
end

function count(res::Resource)
  return length(res.users)
end

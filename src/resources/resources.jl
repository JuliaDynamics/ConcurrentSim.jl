type ResourceKey <: AbstractResourceKey
  priority :: Int64
  schedule_time :: Float64
  preempt :: Bool
  since :: Float64
end

type Request <: GetEvent
  bev :: BaseEvent
  proc :: Process
  function Request(env::AbstractEnvironment)
    req = new()
    req.bev = BaseEvent(env)
    req.proc = active_process(env)
    return req
  end
end

type Resource <: AbstractResource
  env :: AbstractEnvironment
  capacity :: Int
  get_queue :: PriorityQueue{Request, ResourceKey}
  user_list :: PriorityQueue{Process, ResourceKey}
  function Resource(env::AbstractEnvironment, capacity=1)
    res = new()
    res.env = env
    res.capacity = capacity
    if VERSION >= v"0.4-"
      res.get_queue = PriorityQueue(Request, ResourceKey)
      res.users = PriorityQueue(Process, ResourceKey, Order.Reverse)
    else
      res.queue = PriorityQueue{Request, ResourceKey}()
      res.users = PriorityQueue{Process, ResourceKey}(Order.Reverse)
    end
    return res
  end
end

type Release <: PutEvent
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

function Request(res::Resource, id::Uint16, priority::Int64=0, preempt::Bool=false)
  req = Request(res.env)
  res.queue[req] = ResourceKey(priority, id, preempt, 0.0)
  trigger_put(req, res)
  return req
end

function Request(res::Resource, priority::Int64=0, preempt::Bool=false)
  res.eid += 1
  return Request(res, res.eid, priority, preempt)
end

function isless(a::ResourceKey, b::ResourceKey)
  return (a.priority < b.priority) || (a.priority == b.priority && a.preempt < b.preempt) || (a.priority == b.priority && a.preempt == b.preempt && a.schedule_time < b.schedule_time)
end

function show(io::IO, pre::Preempted)
  print(io, "preemption by $(pre.by)")
end

function do_put(res::Resource, put_ev::Release, key)

end

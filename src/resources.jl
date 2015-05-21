using Base.Order

type QueueElement
  ev :: Event
  proc :: Process
  preempt :: Bool
end

type ResourceKey
  priority :: Int64
  id :: Uint16
  time :: Float64
end

type Preempt <: Exception
  cause :: Process
  id :: Uint16
  usage_since :: Float64
end

function isless(a::ResourceKey, b::ResourceKey)
	return (a.priority < b.priority) || (a.priority == b.priority && a.id < b.id)
end

type Resource
  env :: BaseEnvironment
  eid :: Uint16
  capacity :: Int
  queue :: PriorityQueue{QueueElement, ResourceKey}
  user_list :: PriorityQueue{Process, ResourceKey}
  function Resource(env::BaseEnvironment, capacity::Int=1)
    res = new()
    res.env = env
    res.eid = 0
    res.capacity = capacity
    if VERSION >= v"0.4-"
      res.queue = PriorityQueue(QueueElement, ResourceKey)
      res.user_list = PriorityQueue(Process, ResourceKey, Order.Reverse)
    else
      res.queue = PriorityQueue{QueueElement, ResourceKey}()
      res.user_list = PriorityQueue{Process, ResourceKey}(Order.Reverse)
    end
    return res
  end
end

function request(res::Resource, id:: Uint16, priority::Int64, preempt::Bool)
  ev = Event(res.env)
  res.queue[QueueElement(ev, res.env.active_proc, preempt)] = ResourceKey(priority, id, now(res.env))
  trigger_put(Event(res.env), res)
  return ev
end

function request(res::Resource, priority::Int64=0, preempt::Bool=false)
  res.eid += 1
  return request(res, res.eid, priority, preempt)
end

function request(res::Resource, pre::Preempt, priority::Int64=0, preempt::Bool=false)
  return request(res, pre.id, priority, preempt)
end

function release(res::Resource)
  ev = timeout(res.env, 0.0)
  append_callback(ev, (ev)->trigger_put(ev, res))
  trigger_get(Event(res.env), res, res.env.active_proc)
  return ev
end

function trigger_put(ev::Event, res::Resource)
  if length(res.queue) > 0
    (val, key) = peek(res.queue)
    if length(res.user_list) >= res.capacity && val.preempt
      (val_preempt, key_preempt) = peek(res.user_list)
      if key_preempt > key
        dequeue!(res.user_list)
        preempt(res.env, val_preempt, val.proc, key_preempt)
      end
    end
    if length(res.user_list) < res.capacity
      key.time = now(ev.env)
      res.user_list[val.proc] = key
      succeed(val.ev, val)
      dequeue!(res.queue)
    end
  end
end

function trigger_get(ev::Event, res::Resource, proc::Process)
  id::Uint16 = 0
  res.user_list[proc] = ResourceKey(typemax(Int64), id, 0.0)
  dequeue!(res.user_list)
end

function preempt(env::BaseEnvironment, proc::Process, cause::Process, key::ResourceKey)
  ev = Event(env)
  push!(ev.callbacks, proc.execute)
  schedule(ev, true, Preempt(cause, key.id, key.time))
  delete!(proc.target.callbacks, proc.execute)
end

function show(io::IO, pre::Preempt)
  print(io, "Preempted by $(pre.cause): $(pre.id), $(pre.usage_since)")
end

function cause(pre::Preempt)
  return pre.cause
end

function usage_since(pre::Preempt)
  return pre.usage_since
end

function id(pre::Preempt)
  return pre.id
end

function count(res::Resource)
  return length(res.user_list)
end

function capacity(res::Resource)
  return res.capacity
end

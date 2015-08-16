type ResourceKey
  priority :: Int64
  id :: Uint16
  preempt :: Bool
end

type Preempted
  by :: Process
  usage_since :: Float64
end

function isless(a::ResourceKey, b::ResourceKey)
  return (a.priority < b.priority) || (a.priority == b.priority && a.preempt < b.preempt) || (a.priority == b.priority && a.preempt == b.preempt && a.id < b.id)
end

type Resource
  env :: BaseEnvironment
  eid :: Uint16
  capacity :: Int
  queue :: PriorityQueue{Event, ResourceKey}
  user_list :: PriorityQueue{Process, ResourceKey}
  event_process :: Dict{Event, Process}
  process_time :: Dict{Process, Float64}
  function Resource(env::BaseEnvironment, capacity::Int=1)
    res = new()
    res.env = env
    res.eid = 0
    res.capacity = capacity
    if VERSION >= v"0.4-"
      res.queue = PriorityQueue(Event, ResourceKey)
      res.user_list = PriorityQueue(Process, ResourceKey, Order.Reverse)
    else
      res.queue = PriorityQueue{Event, ResourceKey}()
      res.user_list = PriorityQueue{Process, ResourceKey}(Order.Reverse)
    end
    res.event_process = Dict{Event, Process}()
    res.process_time = Dict{Process, Float64}()
    return res
  end
end

function Request(res::Resource, id::Uint16, priority::Int64=0, preempt::Bool=false)
  ev = Event(res.env)
  res.queue[ev] = ResourceKey(priority, id, preempt)
  res.event_process[ev] = active_process(res.env)
  trigger_put(ev, res)
  return ev
end

function Request(res::Resource, priority::Int64=0, preempt::Bool=false)
  res.eid += 1
  return Request(res, res.eid, priority, preempt)
end

function Release(res::Resource)
  ev = Timeout(res.env, 0.0)
  proc = active_process(res.env)
  append_callback(ev, trigger_put, res)
  dequeue!(res.user_list, proc)
  delete!(res.process_time, proc)
  return ev
end

function cancel(res::Resource, req::Event)
  dequeue!(res.queue, req)
end

function trigger_put(event::Event, res::Resource)
  while length(res.queue) > 0
    (ev, key) = peek(res.queue)
    proc = res.event_process[ev]
    if length(res.user_list) >= res.capacity && key.preempt
      (proc_preempt, key_preempt) = peek(res.user_list)
      if key_preempt > key
        dequeue!(res.user_list)
        Interrupt(proc_preempt, Preempted(proc, pop!(res.process_time, proc_preempt)))
      end
    end
    if length(res.user_list) < res.capacity
      res.process_time[proc] = now(res.env)
      res.user_list[proc] = key
      delete!(res.event_process, ev)
      succeed(ev, key.id)
      dequeue!(res.queue)
    else
      break
    end
  end
end

function show(io::IO, pre::Preempted)
  print(io, "Preempted by $(pre.by) in use since $(pre.usage_since)")
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

abstract type ResourceKey end

abstract type AbstractResource end

abstract type ResourceEvent <: AbstractEvent end

struct Put <: ResourceEvent
  bev :: BaseEvent
  function Put(env::Environment)
    new(BaseEvent(env))
  end
end

struct Get <: ResourceEvent
  bev :: BaseEvent
  function Get(env::Environment)
    new(BaseEvent(env))
  end
end

function isless(a::ResourceKey, b::ResourceKey)
  (a.priority < b.priority) || (a.priority == b.priority && a.id < b.id)
end

function trigger_put(put_ev::ResourceEvent, res::AbstractResource)
  queue = DataStructures.PriorityQueue(res.Put_queue)
  while length(queue) > 0
    (put_ev, key) = DataStructures.peek(queue)
    proceed = do_put(res, put_ev, key)
    state(put_ev) == scheduled && DataStructures.dequeue!(res.Put_queue, put_ev)
    proceed ? DataStructures.dequeue!(queue) : break
  end
end

function trigger_get(get_ev::ResourceEvent, res::AbstractResource)
  queue = DataStructures.PriorityQueue(res.Get_queue)
  while length(queue) > 0
    (get_ev, key) = DataStructures.peek(queue)
    proceed = do_get(res, get_ev, key)
    state(get_ev) == scheduled && DataStructures.dequeue!(res.Get_queue, get_ev)
    proceed ? DataStructures.dequeue!(queue) : break
  end
end

function cancel(res::AbstractResource, put_ev::Put)
  DataStructures.dequeue!(res.Put_queue, put_ev)
end

function cancel(res::AbstractResource, get_ev::Get)
  DataStructures.dequeue!(res.Get_queue, get_ev)
end

function capacity(res::AbstractResource)
  res.capacity
end

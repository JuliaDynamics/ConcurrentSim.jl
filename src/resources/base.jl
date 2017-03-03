abstract type ResourceKey end

abstract type AbstractResource{E<:Environment} end

abstract type ResourceEvent{E<:Environment} <: AbstractEvent{E} end

struct Put{E<:Environment} <: ResourceEvent{E}
  bev :: BaseEvent{E}
  function Put{E}(env::E) where E<:Environment
    new(BaseEvent(env))
  end
end

struct Get{E<:Environment} <: ResourceEvent{E}
  bev :: BaseEvent{E}
  function Get{E}(env::E) where E<:Environment
    new(BaseEvent(env))
  end
end

function isless(a::ResourceKey, b::ResourceKey)
  return (a.priority < b.priority) || (a.priority == b.priority && a.id < b.id)
end

function trigger_put{E<:Environment}(put_ev::ResourceEvent{E}, res::AbstractResource{E})
  queue = DataStructures.PriorityQueue(res.Put_queue)
  while length(queue) > 0
    (put_ev, key) = DataStructures.peek(queue)
    proceed = do_put(res, put_ev, key)
    if state(put_ev) == scheduled
      DataStructures.dequeue!(res.Put_queue, put_ev)
    end
    if proceed
      DataStructures.dequeue!(queue)
    else
      break
    end
  end
end

function trigger_get{E<:Environment}(get_ev::ResourceEvent{E}, res::AbstractResource{E})
  queue = DataStructures.PriorityQueue(res.Get_queue)
  while length(queue) > 0
    (get_ev, key) = DataStructures.peek(queue)
    proceed = do_get(res, get_ev, key)
    if state(get_ev) == scheduled
      DataStructures.dequeue!(res.Get_queue, get_ev)
    end
    if proceed
      DataStructures.dequeue!(queue)
    else
      break
    end
  end
end

function cancel{E<:Environment}(res::AbstractResource{E}, put_ev::Put{E})
  DataStructures.dequeue!(res.Put_queue, put_ev)
end

function cancel{E<:Environment}(res::AbstractResource{E}, get_ev::Get{E})
  DataStructures.dequeue!(res.Get_queue, get_ev)
end

function capacity(res::AbstractResource)
  return res.capacity
end

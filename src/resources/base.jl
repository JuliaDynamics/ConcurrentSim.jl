abstract ResourceKey

abstract AbstractResource{E<:Environment}

abstract ResourceEvent{E<:Environment} <: AbstractEvent{E}

type Put{E<:Environment} <: ResourceEvent{E}
  bev :: BaseEvent{E}
  function Put(env::E)
    new(BaseEvent(env))
  end
end

type Get{E<:Environment} <: ResourceEvent{E}
  bev :: BaseEvent{E}
  function Get(env::E)
    new(BaseEvent(env))
  end
end

function isless(a::ResourceKey, b::ResourceKey)
  return (a.priority < b.priority) || (a.priority == b.priority && a.id < b.id)
end

function trigger_put{E<:Environment}(put_ev::ResourceEvent{E}, res::AbstractResource{E})
  queue = PriorityQueue(res.Put_queue)
  while length(queue) > 0
    (put_ev, key) = peek(queue)
    proceed = do_put(res, put_ev, key)
    if state(put_ev) == scheduled
      dequeue!(res.Put_queue, put_ev)
    end
    if proceed
      dequeue!(queue)
    else
      break
    end
  end
end

function trigger_get{E<:Environment}(get_ev::ResourceEvent{E}, res::AbstractResource{E})
  queue = PriorityQueue(res.Get_queue)
  while length(queue) > 0
    (get_ev, key) = peek(queue)
    proceed = do_get(res, get_ev, key)
    if state(get_ev) == scheduled
      dequeue!(res.Get_queue, get_ev)
    end
    if proceed
      dequeue!(queue)
    else
      break
    end
  end
end

function cancel{E<:Environment}(res::AbstractResource{E}, put_ev::Put{E})
  dequeue!(res.Put_queue, put_ev)
end

function cancel{E<:Environment}(res::AbstractResource{E}, get_ev::Get{E})
  dequeue!(res.Get_queue, get_ev)
end

function capacity(res::AbstractResource)
  return res.capacity
end

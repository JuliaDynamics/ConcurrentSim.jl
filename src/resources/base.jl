abstract ResourceKey

abstract AbstractResource{E<:Environment}

abstract ResourceEvent{E<:Environment} <: AbstractEvent{E}

type PutEvent{E<:Environment} <: ResourceEvent{E}
  bev :: BaseEvent{E}
  function PutEvent(env::E)
    new(BaseEvent(env))
  end
end

function PutEvent{E<:Environment}(env::E) :: PutEvent{E}
  PutEvent{E}(env)
end

type GetEvent{E<:Environment} <: ResourceEvent{E}
  bev :: BaseEvent{E}
  function GetEvent(env::E)
    new(BaseEvent(env))
  end
end

function GetEvent{E<:Environment}(env::E) :: GetEvent{E}
  GetEvent{E}(env)
end

function isless(a::ResourceKey, b::ResourceKey)
  return (a.priority < b.priority) || (a.priority == b.priority && a.id < b.id)
end

function trigger_put{E<:Environment}(put_ev::ResourceEvent{E}, res::AbstractResource{E})
  queue = PriorityQueue(res.put_queue)
  while length(queue) > 0
    (put_ev, key) = peek(queue)
    proceed = do_put(res, put_ev, key)
    if state(put_ev) == triggered
      dequeue!(res.put_queue, put_ev)
    end
    if proceed
      dequeue!(queue)
    else
      break
    end
  end
end

function trigger_get{E<:Environment}(get_ev::ResourceEvent{E}, res::AbstractResource{E})
  queue = PriorityQueue(res.get_queue)
  while length(queue) > 0
    (get_ev, key) = peek(queue)
    proceed = do_get(res, get_ev, key)
    if state(get_ev) == triggered
      dequeue!(res.get_queue, get_ev)
    end
    if proceed
      dequeue!(queue)
    else
      break
    end
  end
end

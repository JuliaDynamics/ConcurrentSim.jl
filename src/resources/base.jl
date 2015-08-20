abstract ResourceEvent <: AbstractEvent
abstract PutEvent <: ResourceEvent
abstract GetEvent <: ResourceEvent

abstract AbstractResource

abstract AbstractResourceKey

function trigger_put(ev::ResourceEvent, res::AbstractResource)
  while length(res.put_queue) > 0
    (put_ev, key) = peek(res.put_queue)
    do_put(res, put_ev, key)
    if triggered(put_ev)
      dequeue!(res.put_queue)
    else
      break
    end
  end
end

function trigger_get(ev::ResourceEvent, res::AbstractResource)
  while length(res.get_queue) > 0
    (get_ev, key) = peek(res.get_queue)
    do_get(res, get_ev, key)
    if triggered(get_ev)
      dequeue!(res.get_queue)
    else
      break
    end
  end
end

function cancel(ev::PutEvent)
  dequeue!(ev.res.put_queue, ev)
end

function cancel(ev::GetEvent)
  dequeue!(ev.res.get_queue, ev)
end

function capacity(res::AbstractResource)
  return res.capacity
end

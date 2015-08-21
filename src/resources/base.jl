abstract ResourceEvent <: AbstractEvent
abstract PutEvent <: ResourceEvent
abstract GetEvent <: ResourceEvent

abstract AbstractResource

abstract AbstractResourceKey

function trigger_put(ev::ResourceEvent, res::AbstractResource)
  queue = PriorityQueue(res.put_queue)
  while length(queue) > 0
    (put_ev, key) = peek(queue)
    proceed = do_put(res, put_ev, key)
    if triggered(put_ev)
      dequeue!(res.put_queue, put_ev)
    end
    if proceed
      dequeue!(queue)
    else
      break
    end
  end
end

function trigger_get(ev::ResourceEvent, res::AbstractResource)
  queue = PriorityQueue(res.get_queue)
  while length(queue) > 0
    (get_ev, key) = peek(queue)
    proceed = do_get(res, get_ev, key)
    if triggered(get_ev)
      dequeue!(res.get_queue, get_ev)
    end
    if proceed
      dequeue!(queue)
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

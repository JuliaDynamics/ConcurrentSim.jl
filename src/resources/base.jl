abstract ResourceKey

abstract AbstractResource

function isless(a::ResourceKey, b::ResourceKey)
  return (a.priority < b.priority) || (a.priority == b.priority && a.id < b.id)
end

function trigger_put(sim::Simulation, put_ev::Event, res::AbstractResource)
  queue = PriorityQueue(res.put_queue)
  while length(queue) > 0
    (put_ev, key) = peek(queue)
    proceed = do_put(sim, res, put_ev, key)
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

function trigger_get(sim::Simulation, get_ev::Event, res::AbstractResource)
  queue = PriorityQueue(res.get_queue)
  while length(queue) > 0
    (get_ev, key) = peek(queue)
    proceed = do_get(sim, res, get_ev, key)
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

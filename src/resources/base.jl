abstract AbstractResource

function trigger_put(sim::Simulation, ev::Event, res::AbstractResource)
  queue = res.put_queue
  while length(queue) > 0
    (put_ev, key) = peek(queue)
    if do_put(sim, res, put_ev)
      dequeue!(queue)
    else
      break
    end
  end
end

function trigger_get(sim::Simulation, ev::Event, res::AbstractResource)
  queue = res.get_queue
  while length(queue) > 0
    (get_ev, key) = peek(queue)
    if do_get(sim, res, get_ev)
      dequeue!(queue)
    else
      break
    end
  end
end

function capacity(res::AbstractResource)
  return res.capacity
end

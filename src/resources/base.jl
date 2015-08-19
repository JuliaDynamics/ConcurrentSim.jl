abstract ResourceEvent <: AbstractEvent
abstract PutEvent <: ResourceEvent
abstract GetEvent <: ResourceEvent

abstract AbstractResource

abstract AbstractResourceKey

type Preempted
  by :: Process
  usage_since :: Float64
end

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

function trigger_get(res::AbstractResource, ev::ResourceEvent)

end

function capacity(res::AbstractResource)
  return res.capacity
end

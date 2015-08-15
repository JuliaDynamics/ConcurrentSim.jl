type ContainerKey{T<:Number}
  priority :: Int64
  id :: Uint16
  amount :: T
end

function isless(a::ContainerKey, b::ContainerKey)
  return (a.priority < b.priority) || (a.priority == b.priority && a.id < b.id)
end

type Container{T<:Number}
  env :: BaseEnvironment
  eid :: Uint16
  level :: T
  capacity :: T
  put_queue :: PriorityQueue{Event, ContainerKey{T}}
  get_queue :: PriorityQueue{Event, ContainerKey{T}}
  function Container(env::BaseEnvironment, capacity::T, level::T=zero(T))
    cont = new()
    cont.env = env
    cont.eid = 0
    cont.capacity = capacity
    cont.level = level
    if VERSION >= v"0.4-"
      cont.put_queue = PriorityQueue(Event, ContainerKey{T})
      cont.get_queue = PriorityQueue(Event, ContainerKey{T})
    else
      cont.put_queue = PriorityQueue{Event, ContainerKey{T}}()
      cont.get_queue = PriorityQueue{Event, ContainerKey{T}}()
    end
    return cont
  end
end

function Put{T<:Number}(cont::Container, amount::T, priority::Int64=0)
  cont.eid += 1
  ev = Event(cont.env)
  cont.put_queue[ev] = ContainerKey{T}(priority, cont.eid, amount)
  push!(ev.callbacks, (ev)->trigger_get(ev, cont))
  trigger_put(Event(cont.env), cont)
  return ev
end

function Get{T<:Number}(cont::Container, amount::T, priority::Int64=0)
  cont.eid += 1
  ev = Event(cont.env)
  cont.get_queue[ev] = ContainerKey{T}(priority, cont.eid, amount)
  push!(ev.callbacks, (ev)->trigger_put(ev, cont))
  trigger_get(Event(cont.env), cont)
  return ev
end

function trigger_put(event::Event, cont::Container)
  while length(cont.put_queue) > 0
    (ev, key) = peek(cont.put_queue)
    if cont.level + key.amount <= cont.capacity
      cont.level += key.amount
      schedule(ev)
      dequeue!(cont.put_queue)
    else
      break
    end
  end
end

function trigger_get{T}(event::Event, cont::Container{T})
  while length(cont.get_queue) > 0
    (ev, key) = peek(cont.get_queue)
    if cont.level - key.amount >= zero(T)
      cont.level -= key.amount
      schedule(ev)
      dequeue!(cont.get_queue)
    else
      break
    end
  end
end

function capacity(cont::Container)
  return cont.capacity
end

function level(cont::Container)
  return cont.level
end

type ContainerKey{T<:Number}
  priority :: Int64
  id :: Uint16
  amount :: T
end

type Put <: AbstractEvent
  bev :: BaseEvent
  function Put(env::AbstractEnvironment)
    put = new()
    put.bev = BaseEvent(env)
    return put
  end
end

type Get <: AbstractEvent
  bev :: BaseEvent
  function Get(env::AbstractEnvironment)
    get = new()
    get.bev = BaseEvent(env)
    return get
  end
end

type Container{T<:Number}
  env :: Environment
  eid :: Uint16
  level :: T
  capacity :: T
  put_queue :: PriorityQueue{Put, ContainerKey{T}}
  get_queue :: PriorityQueue{Get, ContainerKey{T}}
  function Container(env::Environment, capacity::T, level::T=zero(T))
    cont = new()
    cont.env = env
    cont.eid = 0
    cont.capacity = capacity
    cont.level = level
    if VERSION >= v"0.4-"
      cont.put_queue = PriorityQueue(Put, ContainerKey{T})
      cont.get_queue = PriorityQueue(Get, ContainerKey{T})
    else
      cont.put_queue = PriorityQueue{Put, ContainerKey{T}}()
      cont.get_queue = PriorityQueue{Get, ContainerKey{T}}()
    end
    return cont
  end
end

function Put{T<:Number}(cont::Container, amount::T, priority::Int64=0)
  cont.eid += 1
  put = Put(cont.env)
  cont.put_queue[put] = ContainerKey{T}(priority, cont.eid, amount)
  append_callback(put, trigger_get, cont)
  trigger_put(put, cont)
  return put
end

function Get{T<:Number}(cont::Container, amount::T, priority::Int64=0)
  cont.eid += 1
  get = Get(cont.env)
  cont.get_queue[get] = ContainerKey{T}(priority, cont.eid, amount)
  append_callback(get, trigger_put, cont)
  trigger_get(get, cont)
  return get
end

function isless(a::ContainerKey, b::ContainerKey)
  return (a.priority < b.priority) || (a.priority == b.priority && a.id < b.id)
end

function trigger_put(event::AbstractEvent, cont::Container)
  while length(cont.put_queue) > 0
    (ev, key) = peek(cont.put_queue)
    if cont.level + key.amount <= cont.capacity
      cont.level += key.amount
      succeed(ev)
      dequeue!(cont.put_queue)
    else
      break
    end
  end
end

function trigger_get{T}(event::AbstractEvent, cont::Container{T})
  while length(cont.get_queue) > 0
    (ev, key) = peek(cont.get_queue)
    if cont.level - key.amount >= zero(T)
      cont.level -= key.amount
      succeed(ev)
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

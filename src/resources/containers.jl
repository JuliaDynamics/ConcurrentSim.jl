type ContainerKey <: AbstractResourceKey
  priority :: Int
  id :: Int
end

type ContainerPut{T<:Number} <: PutEvent
  bev :: BaseEvent
  proc :: Process
  res :: AbstractResource
  amount :: T
  function ContainerPut(res::AbstractResource, amount::T)
    put = new()
    put.bev = BaseEvent(res.env)
    put.proc = active_process(res.env)
    put.res = res
    put.amount = amount
    return put
  end
end

type ContainerGet{T<:Number} <: GetEvent
  bev :: BaseEvent
  proc :: Process
  res :: AbstractResource
  amount :: T
  function ContainerGet(res::AbstractResource, amount::T)
    get = new()
    get.bev = BaseEvent(res.env)
    get.proc = active_process(res.env)
    get.res = res
    get.amount = amount
    return get
  end
end

type Container{T<:Number} <: AbstractResource
  env :: Environment
  level :: T
  capacity :: T
  seid :: Int
  put_queue :: PriorityQueue{ContainerPut{T}, ContainerKey}
  get_queue :: PriorityQueue{ContainerGet{T}, ContainerKey}
  function Container(env::Environment, capacity::T=typemax(T), level::T=zero(T))
    cont = new()
    cont.env = env
    cont.capacity = capacity
    cont.level = level
    cont.seid = 0
    if VERSION >= v"0.4-"
      cont.put_queue = PriorityQueue(ContainerPut{T}, ContainerKey)
      cont.get_queue = PriorityQueue(ContainerGet{T}, ContainerKey)
    else
      cont.put_queue = PriorityQueue{ContainerPut{T}, ContainerKey}()
      cont.get_queue = PriorityQueue{ContainerGet{T}, ContainerKey}()
    end
    return cont
  end
end

function Put{T<:Number}(cont::Container{T}, amount::T, priority::Int=0)
  put = ContainerPut{T}(cont, amount)
  cont.put_queue[put] = ContainerKey(priority, cont.seid += 1)
  append_callback(put, trigger_get, cont)
  trigger_put(put, cont)
  return put
end

function Get{T<:Number}(cont::Container{T}, amount::T, priority::Int=0)
  get = ContainerGet{T}(cont, amount)
  cont.get_queue[get] = ContainerKey(priority, cont.seid += 1)
  append_callback(get, trigger_put, cont)
  trigger_get(get, cont)
  return get
end

function isless(a::ContainerKey, b::ContainerKey)
  return (a.priority < b.priority) || (a.priority == b.priority && a.id < b.id)
end

function do_put(cont::Container, ev::ContainerPut, key::ContainerKey)
  if cont.capacity - cont.level >= ev.amount
    cont.level += ev.amount
    succeed(ev)
    return true
  end
  return false
end

function do_get(cont::Container, ev::ContainerGet, key::ContainerKey)
  if cont.level >= ev.amount
    cont.level -= ev.amount
    succeed(ev)
    return true
  end
  return false
end

function level(cont::Container)
  return cont.level
end

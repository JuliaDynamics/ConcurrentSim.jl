type ContainerKey <: AbstractResourceKey
  priority :: Int64
  schedule_time :: Float64
end

type PutContainer{T<:Number} <: PutEvent
  bev :: BaseEvent
  proc :: Process
  res :: AbstractResource
  amount :: T
  function PutContainer(res::AbstractResource, amount::T)
    put = new()
    put.bev = BaseEvent(res.env)
    put.proc = active_process(res.env)
    put.res = res
    put.amount = amount
    return put
  end
end

type GetContainer{T<:Number} <: GetEvent
  bev :: BaseEvent
  proc :: Process
  res :: AbstractResource
  amount :: T
  function GetContainer(res::AbstractResource, amount::T)
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
  put_queue :: PriorityQueue{PutContainer{T}, ContainerKey}
  get_queue :: PriorityQueue{GetContainer{T}, ContainerKey}
  function Container(env::Environment, capacity::T, level::T=zero(T))
    cont = new()
    cont.env = env
    cont.capacity = capacity
    cont.level = level
    if VERSION >= v"0.4-"
      cont.put_queue = PriorityQueue(PutContainer{T}, ContainerKey)
      cont.get_queue = PriorityQueue(GetContainer{T}, ContainerKey)
    else
      cont.put_queue = PriorityQueue{PutContainer{T}, ContainerKey}()
      cont.get_queue = PriorityQueue{GetContainer{T}, ContainerKey}()
    end
    return cont
  end
end

function Put{T<:Number}(cont::Container{T}, amount::T, priority::Int64=0)
  put = PutContainer{T}(cont, amount)
  cont.put_queue[put] = ContainerKey(priority, now(cont.env))
  append_callback(put, trigger_get, cont)
  trigger_put(put, cont)
  return put
end

function Get{T<:Number}(cont::Container{T}, amount::T, priority::Int64=0)
  get = GetContainer{T}(cont, amount)
  cont.get_queue[get] = ContainerKey(priority, now(cont.env))
  append_callback(get, trigger_put, cont)
  trigger_get(get, cont)
  return get
end

function isless(a::ContainerKey, b::ContainerKey)
  return (a.priority < b.priority) || (a.priority == b.priority && a.schedule_time < b.schedule_time)
end

function do_put(cont::Container, ev::PutContainer, key::ContainerKey)
  if cont.capacity - cont.level >= ev.amount
    cont.level += ev.amount
    succeed(ev)
  end
end

function do_get(cont::Container, ev::GetContainer, key::ContainerKey)
  if cont.level >= ev.amount
    cont.level -= ev.amount
    succeed(ev)
  end
end

function level(cont::Container)
  return cont.level
end

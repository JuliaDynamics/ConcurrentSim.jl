type StoreKey <: AbstractResourceKey
  priority :: Int64
  id :: Float64
end

type PutStore{T} <: PutEvent
  bev :: BaseEvent
  proc :: Process
  res :: AbstractResource
  item :: T
  function PutStore(res::AbstractResource, item::T)
    put = new()
    put.bev = BaseEvent(res.env)
    put.proc = active_process(res.env)
    put.res = res
    put.item = item
    return put
  end
end

type GetStore <: GetEvent
  bev :: BaseEvent
  proc :: Process
  res :: AbstractResource
  filter :: Function
  function GetStore(res::AbstractResource, filter::Function)
    get = new()
    get.bev = BaseEvent(res.env)
    get.proc = active_process(res.env)
    get.res = res
    get.filter = filter
    return get
  end
end

type Store{T} <: AbstractResource
  env :: Environment
  capacity :: Int64
  items :: Set{T}
  seid :: Int64
  put_queue :: PriorityQueue{PutStore{T}, StoreKey}
  get_queue :: PriorityQueue{GetStore, StoreKey}
  function Store(env::Environment, capacity::Int64)
    sto = new()
    sto.env = env
    sto.capacity = capacity
    sto.items = Set{T}()
    sto.seid = 0
    if VERSION >= v"0.4-"
      sto.put_queue = PriorityQueue(PutStore{T}, StoreKey)
      sto.get_queue = PriorityQueue(GetStore, StoreKey)
    else
      sto.put_queue = PriorityQueue{PutStore{T}, StoreKey}()
      sto.get_queue = PriorityQueue{GetStore, StoreKey}()
    end
    return sto
  end
end

function Store{T}(env::Environment, ::Type{T}, capacity::Int64=1)
  return Store{T}(env, capacity)
end

function Put{T}(sto::Store{T}, item::T, priority::Int64=0)
  put = PutStore{T}(sto, item)
  sto.put_queue[put] = StoreKey(priority, sto.seid+=1)
  append_callback(put, trigger_get, sto)
  trigger_put(put, sto)
  return put
end

function Get{T}(sto::Store{T}, filter::Function=(item::T)->true, priority::Int64=0)
  get = GetStore(sto, filter)
  sto.get_queue[get] = StoreKey(priority, sto.seid+=1)
  append_callback(get, trigger_put, sto)
  trigger_get(get, sto)
  return get
end

function isless(a::StoreKey, b::StoreKey)
  return (a.priority < b.priority) || (a.priority == b.priority && a.id < b.id)
end

function do_put(sto::Store, ev::PutStore, key::StoreKey)
  if length(sto.items) < sto.capacity
    push!(sto.items, ev.item)
    succeed(ev)
  end
end

function do_get(sto::Store, ev::GetStore, key::StoreKey)
  for item in sto.items
    if ev.filter(item)
      delete!(sto.items, item)
      succeed(ev, item)
      break
    end
  end
end


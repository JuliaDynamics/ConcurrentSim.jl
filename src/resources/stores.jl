struct StorePutKey{T} <: ResourceKey
  priority :: Int
  id :: UInt
  item :: T
end

struct StoreGetKey <: ResourceKey
  priority :: Int
  id :: UInt
  filter :: Function
end

mutable struct Store{T} <: AbstractResource
  env :: Environment
  capacity :: UInt
  items :: Set{T}
  seid :: UInt
  Put_queue :: DataStructures.PriorityQueue{Put, StorePutKey{T}}
  Get_queue :: DataStructures.PriorityQueue{Get, StoreGetKey}
  function Store{T}(env::Environment, capacity::UInt) where {T}
    new(env, capacity, Set{T}(), zero(UInt), DataStructures.PriorityQueue(Put, StorePutKey{T}), DataStructures.PriorityQueue(Get, StoreGetKey))
  end
end

function Store(t::Type, env::Environment, capacity::UInt=typemax(UInt))
  Store{t}(env, capacity)
end

function Put{T}(sto::Store{T}, item::T; priority::Int=0) :: Put
  put_ev = Put(sto.env)
  sto.Put_queue[put_ev] = StorePutKey(priority, sto.seid+=one(UInt), item)
  append_callback(trigger_get, put_ev, sto)
  trigger_put(put_ev, sto)
  return put_ev
end

function get_any_item{T}(::T) :: Bool
  return true
end

function Get{T}(sto::Store{T}, filter::Function=get_any_item; priority::Int=0) :: Get
  get_ev = Get(sto.env)
  sto.Get_queue[get_ev] = StoreGetKey(priority, sto.seid+=one(UInt), filter)
  append_callback(trigger_put, get_ev, sto)
  trigger_get(get_ev, sto)
  return get_ev
end

function do_put{T}(sto::Store{T}, put_ev::Put, key::StorePutKey{T}) :: Bool
  if length(sto.items) < sto.capacity
    push!(sto.items, key.item)
    schedule(put_ev.bev)
  end
  return false
end

function do_get{T}(sto::Store{T}, get_ev::Get, key::StoreGetKey) :: Bool
  for item in sto.items
    if key.filter(item)
      delete!(sto.items, item)
      schedule(get_ev.bev, value=item)
      break
    end
  end
  return true
end

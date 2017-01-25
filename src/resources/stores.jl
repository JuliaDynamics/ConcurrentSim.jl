type StorePutKey{T} <: ResourceKey
  priority :: Int
  id :: UInt
  item :: T
end

type StoreGetKey <: ResourceKey
  priority :: Int
  id :: UInt
  filter :: Function
end

type Store{T, E<:Environment} <: AbstractResource{E}
  env :: E
  capacity :: UInt
  items :: Set{T}
  seid :: UInt
  Put_queue :: DataStructures.PriorityQueue{Put{E}, StorePutKey{T}}
  Get_queue :: DataStructures.PriorityQueue{Get{E}, StoreGetKey}
  function Store(env::E, capacity::UInt)
    new(env, capacity, Set{T}(), zero(UInt), DataStructures.PriorityQueue(Put{E}, StorePutKey{T}), DataStructures.PriorityQueue(Get{E}, StoreGetKey))
  end
end

function Store{E<:Environment}(t::Type, env::E, capacity::UInt=typemax(UInt)) :: Store{t, E}
  Store{t, E}(env, capacity)
end

function Put{T, E<:Environment}(sto::Store{T, E}, item::T; priority::Int=0) :: Put{E}
  put_ev = Put{E}(sto.env)
  sto.Put_queue[put_ev] = StorePutKey(priority, sto.seid+=one(UInt), item)
  append_callback(trigger_get, put_ev, sto)
  trigger_put(put_ev, sto)
  return put_ev
end

function get_any_item{T}(::T) :: Bool
  return true
end

function Get{T, E<:Environment}(sto::Store{T, E}, filter::Function=get_any_item; priority::Int=0) :: Get{E}
  get_ev = Get{E}(sto.env)
  sto.Get_queue[get_ev] = StoreGetKey(priority, sto.seid+=one(UInt), filter)
  append_callback(trigger_put, get_ev, sto)
  trigger_get(get_ev, sto)
  return get_ev
end

function do_put{T, E<:Environment}(sto::Store{T}, put_ev::Put{E}, key::StorePutKey{T}) :: Bool
  if length(sto.items) < sto.capacity
    push!(sto.items, key.item)
    schedule(put_ev.bev)
  end
  return false
end

function do_get{T, E<:Environment}(sto::Store{T}, get_ev::Get{E}, key::StoreGetKey) :: Bool
  for item in sto.items
    if key.filter(item)
      delete!(sto.items, item)
      schedule(get_ev.bev, value=item)
      break
    end
  end
  return true
end

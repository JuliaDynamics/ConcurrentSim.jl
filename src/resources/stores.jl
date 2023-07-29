struct StorePutKey{N, T<:Number} <: ResourceKey
  id :: UInt
  item :: N
  priority :: T
end

struct StoreGetKey{T<:Number} <: ResourceKey
  id :: UInt
  filter :: Function
  priority :: T
end

mutable struct Store{N, T<:Number} <: AbstractResource
  env :: Environment
  capacity :: UInt
  load :: UInt
  items :: Dict{N, UInt}
  seid :: UInt
  put_queue :: DataStructures.PriorityQueue{Put, StorePutKey{N, T}}
  get_queue :: DataStructures.PriorityQueue{Get, StoreGetKey{T}}
  function Store{N, T}(env::Environment; capacity::UInt=typemax(UInt)) where {N, T<:Number}
    new(env, capacity, zero(UInt), Dict{N, UInt}(), zero(UInt), DataStructures.PriorityQueue{Put, StorePutKey{N, T}}(), DataStructures.PriorityQueue{Get, StoreGetKey{T}}())
  end
end

function Store{N}(env::Environment; capacity::UInt=typemax(UInt)) where {N}
  Store{N, Int}(env; capacity)
end

function put(sto::Store{N, T}, item::N; priority::T=zero(T)) where {N, T<:Number}
  put_ev = Put(sto.env)
  sto.put_queue[put_ev] = StorePutKey{N, T}(sto.seid+=one(UInt), item, priority)
  @callback trigger_get(put_ev, sto)
  trigger_put(put_ev, sto)
  put_ev
end

get_any_item(::T) where T = true

function get(sto::Store{N, T}, filter::Function=get_any_item; priority::T=zero(T)) where {N, T<:Number}
  get_ev = Get(sto.env)
  sto.get_queue[get_ev] = StoreGetKey(sto.seid+=one(UInt), filter, priority)
  @callback trigger_put(get_ev, sto)
  trigger_get(get_ev, sto)
  get_ev
end

function do_put(sto::Store{N, T}, put_ev::Put, key::StorePutKey{N, T}) where {N, T<:Number}
  if sto.load < sto.capacity
    sto.load += one(UInt)
    sto.items[key.item] = get(sto.items, key.item, zero(UInt)) + one(UInt)
    schedule(put_ev)
  end
  false
end

function do_get(sto::Store{N, T}, get_ev::Get, key::StoreGetKey{T}) where {N, T<:Number}
  for (item, number) in sto.items
    if key.filter(item)
      sto.load -= one(UInt)
      if number === one(UInt)
        delete!(sto.items, item)
      else
        sto.items[item] = number - one(UInt)
      end
      schedule(get_ev; value=item)
      break
    end
  end
  true
end

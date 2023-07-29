struct StorePutKey{N<:Number, T} <: ResourceKey
  priority :: N
  id :: UInt
  item :: T
end

struct StoreGetKey{N<:Number} <: ResourceKey
  priority :: N
  id :: UInt
  filter :: Function
end

mutable struct Store{T, N<:Number} <: AbstractResource
  env :: Environment
  capacity :: UInt
  load :: UInt
  items :: Dict{T, UInt}
  seid :: UInt
  put_queue :: DataStructures.PriorityQueue{Put, StorePutKey{N, T}}
  get_queue :: DataStructures.PriorityQueue{Get, StoreGetKey{N}}
  function Store{T,N}(env::Environment; capacity::UInt=typemax(UInt)) where {T, N<:Number}
    new(env, capacity, zero(UInt), Dict{T, UInt}(), zero(UInt), DataStructures.PriorityQueue{Put, StorePutKey{N, T}}(), DataStructures.PriorityQueue{Get, StoreGetKey{N}}())
  end
end

function Store{T}(env::Environment; capacity::UInt=typemax(UInt)) where {T}
  Store{T,Int}(env; capacity)
end

function put(sto::Store{T, N}, item::T; priority::N=zero(N)) where {T, N<:Number}
  put_ev = Put(sto.env)
  sto.put_queue[put_ev] = StorePutKey{N, T}(priority, sto.seid+=one(UInt), item)
  @callback trigger_get(put_ev, sto)
  trigger_put(put_ev, sto)
  put_ev
end

get_any_item(::T) where T = true

function get(sto::Store{T, N}, filter::Function=get_any_item; priority::N=zero(N)) where {T, N<:Number}
  get_ev = Get(sto.env)
  sto.get_queue[get_ev] = StoreGetKey(priority, sto.seid+=one(UInt), filter)
  @callback trigger_put(get_ev, sto)
  trigger_get(get_ev, sto)
  get_ev
end

function do_put(sto::Store{T, N}, put_ev::Put, key::StorePutKey{N,T}) where {T, N<:Number}
  if sto.load < sto.capacity
    sto.load += one(UInt)
    sto.items[key.item] = get(sto.items, key.item, zero(UInt)) + one(UInt)
    schedule(put_ev)
  end
  false
end

function do_get(sto::Store{T, N}, get_ev::Get, key::StoreGetKey{N}) where {T, N<:Number}
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

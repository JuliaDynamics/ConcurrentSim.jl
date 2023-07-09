struct StorePutKey{T} <: ResourceKey
  priority :: Number
  id :: UInt
  item :: T
  StorePutKey{T}(priority, id, item) where T = new(priority, id, item)
end

struct StoreGetKey <: ResourceKey
  priority :: Number
  id :: UInt
  filter :: Function
end

mutable struct Store{T} <: AbstractResource
  env :: Environment
  capacity :: UInt
  load :: UInt
  items :: Dict{T, UInt}
  seid :: UInt
  put_queue :: DataStructures.PriorityQueue{Put, StorePutKey{T}}
  get_queue :: DataStructures.PriorityQueue{Get, StoreGetKey}
  function Store{T}(env::Environment; capacity::UInt=typemax(UInt)) where {T}
    new(env, capacity, zero(UInt), Dict{T, UInt}(), zero(UInt), DataStructures.PriorityQueue{Put, StorePutKey{T}}(), DataStructures.PriorityQueue{Get, StoreGetKey}())
  end
end

function put(sto::Store{T}, item::T; priority::Number=0) where T
  put_ev = Put(sto.env)
  sto.put_queue[put_ev] = StorePutKey{T}(priority, sto.seid+=one(UInt), item)
  @callback trigger_get(put_ev, sto)
  trigger_put(put_ev, sto)
  put_ev
end

get_any_item(::T) where T = true

function get(sto::Store{T}, filter::Function=get_any_item; priority::Number=0) where T
  get_ev = Get(sto.env)
  sto.get_queue[get_ev] = StoreGetKey(priority, sto.seid+=one(UInt), filter)
  @callback trigger_put(get_ev, sto)
  trigger_get(get_ev, sto)
  get_ev
end

function do_put(sto::Store{T}, put_ev::Put, key::StorePutKey{T}) where {T}
  if sto.load < sto.capacity
    sto.load += one(UInt)
    sto.items[key.item] = get(sto.items, key.item, zero(UInt)) + one(UInt)
    schedule(put_ev)
  end
  false
end

function do_get(sto::Store{T}, get_ev::Get, key::StoreGetKey) where {T}
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

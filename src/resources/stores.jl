struct StorePutKey{T} <: ResourceKey
  priority :: Int
  id :: UInt
  item :: T
  StorePutKey{T}(priority, id, item) where T = new(priority, id, item)
end

struct StoreGetKey <: ResourceKey
  priority :: Int
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
  function Store{T}(env::Environment; capacity=typemax(UInt)) where {T}
    new(env, UInt(capacity), zero(UInt), Dict{T, UInt}(), zero(UInt), DataStructures.PriorityQueue{Put, StorePutKey{T}}(), DataStructures.PriorityQueue{Get, StoreGetKey}())
  end
end

function put!(sto::Store{T}, item::T; priority::Int=0) where T
  put_ev = Put(sto.env)
  sto.put_queue[put_ev] = StorePutKey{T}(priority, sto.seid+=one(UInt), item)
  @callback trigger_get(put_ev, sto)
  trigger_put(put_ev, sto)
  put_ev
end

get_any_item(::T) where T = true

function get(sto::Store{T}, filter::Function=get_any_item; priority::Int=0) where T
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

"""
    isready(::Store)

Returns `true` if the store is not empty, similarly to the meaning of `isready` for `Base.Channel`.

```jldoctest
julia> sim = Simulation(); store = Store{Symbol}(sim); isready(store)
false

julia> put!(store, :message); isready(store)
true
```
"""
isready(sto::Store) = sto.load > 0

"""
    islocked(::Store)

Returns `true` if the store is full, similarly to the meaning of `islocked` for `Base.ReentrantLock`.

```jldoctest
julia> sim = Simulation(); store = Store{Symbol}(sim; capacity=2); islocked(store)
false

julia> put!(store, :message); islocked(store)
false

julia> put!(store, :another_message); islocked(store)
true
```
"""
islocked(sto::Store) = sto.load==sto.capacity

unlock(::Store) = error("There is no well defined way to \"unlock\" a store. Instead of attempting `unlock` consider using `pop!(::Store)` or use a `Resource` instead of a `Store`.")
lock(::Store) = error("There is no well defined way to \"lock\" a store. Instead of attempting `lock` consider using `put!(::Store, ...)` or use a `Resource` instead of a `Store`.")

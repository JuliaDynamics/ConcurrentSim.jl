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
  items :: Set{T}
  seid :: UInt
  put_queue :: DataStructures.PriorityQueue{Put, StorePutKey{T}}
  get_queue :: DataStructures.PriorityQueue{Get, StoreGetKey}
  function Store{T}(env::Environment; capacity::UInt=typemax(UInt)) where {T}
    new(env, capacity, Set{T}(), zero(UInt), DataStructures.PriorityQueue{Put, StorePutKey{T}}(), DataStructures.PriorityQueue{Get, StoreGetKey}())
  end
end

function put(sto::Store{T}, item::T; priority::Int=0) where T
  put_ev = Put(sto.env)
  sto.put_queue[put_ev] = StorePutKey{T}(priority, sto.seid+=one(UInt), item)
  @callback trigger_get(put_ev, sto)
  trigger_put(put_ev, sto)
  put_ev
end

"""
  put(sto::Store{T}, item::T, preempt::Bool=false,
        filter::Function=get_any_item) where T

Put an `item` in a `Store` and allow for preemption using `filter` to select
  which item to remove from the `Store` when preempting.

This method requires that T be a mutable struct with the fields:
- `:priority::Int`: Integer specifying the priority of that `item` (the more
  negative, the higher the priority).
- `:process::Dict{Store{T}, Process}`: Dictionary mapping the storage process
  of the `item` to the `Store` object. This is used to know which `Process` to
  interrupt when an `item` is being stored in more than one `Store`.
"""
function put(sto::Store{T}, item::T, preempt::Bool=false, filter::Function=get_any_item) where T
    @assert :priority in fieldnames(T) "Preemption requires that the item being stored have :priority as one of its fields."
    @assert :process in fieldnames(T) && item.process isa Dict{Store{T},Process} "Preemption requires that the item being stored have :process (Dict) as one of its fields."
    if preempt && !isempty(sto.items) && item.priority < maximum([itm.priority for itm in sto.items]) #if the new item priority is higher than the priority of at least one of the items in the store, preempt
        #remove item from store
        stoitems = [itm for itm in sto.items] #original items in sto
        get(sto, filter) #get item from store
        pitem = setdiff(stoitems, [itm for itm in sto.items])[1] #find removed item
        proc = pitem.process[sto] #process to interrupt
        interrupt(proc, item) #interrupt process on removed item identify item causing the preemption
        #put new item into the queue
        put_ev = put(sto, item, priority = item.priority)
    else
        put_ev = put(sto, item, priority = item.priority) #regular put if no preemption or not at full capactiy
    end
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
  if length(sto.items) < sto.capacity
    push!(sto.items, key.item)
    schedule(put_ev)
  end
  false
end

function do_get(sto::Store{T}, get_ev::Get, key::StoreGetKey) where {T}
  for item in sto.items
    if key.filter(item)
      delete!(sto.items, item)
      schedule(get_ev; value=item)
      break
    end
  end
  true
end

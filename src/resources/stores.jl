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

type Store{T} <: AbstractResource
  capacity :: UInt
  items :: Set{T}
  seid :: UInt
  put_queue :: PriorityQueue{Event, StorePutKey{T}}
  get_queue :: PriorityQueue{Event, StoreGetKey}
  function Store(capacity::UInt=typemax(UInt))
    sto = new()
    sto.capacity = capacity
    sto.items = Set{T}()
    sto.seid = zero(UInt)
    sto.put_queue = PriorityQueue(Event, StorePutKey{T})
    sto.get_queue = PriorityQueue(Event, StoreGetKey)
    return sto
  end
end

function Store(t::Type)
  Store{t}()
end

function put{T}(sim::Simulation, sto::Store{T}, item::T; priority::Int=0) :: Event
  put_ev = Event()
  sto.put_queue[put_ev] = StorePutKey(priority, sto.seid+=one(UInt), item)
  append_callback(put_ev, trigger_get, sto)
  trigger_put(sim, put_ev, sto)
  return put_ev
end

function get{T}(sim::Simulation, sto::Store{T}, filter::Function=(item::T)->true; priority::Int=0) :: Event
  get_ev = Event()
  sto.get_queue[get_ev] = StoreGetKey(priority, sto.seid+=one(UInt), filter)
  append_callback(get_ev, trigger_put, sto)
  trigger_get(sim, get_ev, sto)
  return get_ev
end

function do_put{T}(sim::Simulation, sto::Store{T}, put_ev::Event, key::StorePutKey{T}) :: Bool
  if length(sto.items) < sto.capacity
    push!(sto.items, key.item)
    schedule(sim, put_ev)
  end
  return false
end

function do_get{T}(sim::Simulation, sto::Store{T}, get_ev::Event, key::StoreGetKey) :: Bool
  for item in sto.items
    if key.filter(item)
      delete!(sto.items, item)
      schedule(sim, get_ev, value=item)
      break
    end
  end
  return true
end

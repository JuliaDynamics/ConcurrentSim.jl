type ContainerKey{N<:Number} <: ResourceKey
  priority :: Int
  id :: UInt
  amount :: N
end

type Container{N<:Number} <: AbstractResource
  capacity :: N
  level :: N
  seid :: UInt
  put_queue :: PriorityQueue{Event, ContainerKey{N}}
  get_queue :: PriorityQueue{Event, ContainerKey{N}}
  function Container(capacity::N=one(N); level::N=zero(N))
    con = new()
    con.capacity = capacity
    con.level = level
    con.seid = zero(UInt)
    con.put_queue = PriorityQueue(Event, ContainerKey{N})
    con.get_queue = PriorityQueue(Event, ContainerKey{N})
    return con
  end
end

function Container{N}(capacity::N; level::N=zero(N))
  Container{N}(capacity, level=level)
end

typealias Resource Container{Int}

request{N}(sim::Simulation, con::Container{N}; priority::Int=0) = put(sim, con, one(N), priority=priority)

function put{N}(sim::Simulation, con::Container{N}, amount::N; priority::Int=0) :: Event
  put_ev = Event()
  con.put_queue[put_ev] = ContainerKey(priority, con.seid+=one(UInt), amount)
  append_callback(put_ev, trigger_get, con)
  trigger_put(sim, put_ev, con)
  return put_ev
end

release{N}(sim::Simulation, con::Container{N}; priority::Int=0) = get(sim, con, one(N), priority=priority)

function get{N}(sim::Simulation, con::Container{N}, amount::N; priority::Int=0) :: Event
  get_ev = Event()
  con.get_queue[get_ev] = ContainerKey(priority, con.seid+=one(UInt), amount)
  append_callback(get_ev, trigger_put, con)
  trigger_get(sim, get_ev, con)
  return get_ev
end

function do_put{N}(sim::Simulation, con::Container{N}, put_ev::Event, key::ContainerKey) :: Bool
  if con.level + key.amount <= con.capacity
    schedule(sim, put_ev)
    con.level += key.amount
    return true
  end
  return false
end

function do_get{N}(sim::Simulation, con::Container{N}, get_ev::Event, key::ContainerKey) :: Bool
  if con.level - key.amount >= zero(N)
    schedule(sim, get_ev)
    con.level -= key.amount
    return true
  end
  return false
end

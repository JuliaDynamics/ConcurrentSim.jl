struct ContainerKey{N<:Number} <: ResourceKey
  priority :: Int
  id :: UInt
  amount :: N
end

mutable struct Container{N<:Number} <: AbstractResource
  env :: Environment
  capacity :: N
  level :: N
  seid :: UInt
  put_queue :: DataStructures.PriorityQueue{Put, ContainerKey{N}}
  get_queue :: DataStructures.PriorityQueue{Get, ContainerKey{N}}
  function Container{N}(env::Environment, capacity::N=one(N); level::N=zero(N)) where {N<:Number}
    new(env, capacity, level, zero(UInt), DataStructures.PriorityQueue{Put, ContainerKey{N}}(), DataStructures.PriorityQueue{Get, ContainerKey{N}}())
  end
end

function Container(env::Environment, capacity::N=one(N); level::N=zero(N)) where N<:Number
  Container{N}(env, capacity, level=level)
end

const Resource = Container{Int}

function put(con::Container{N}, amount::N; priority::Int=0) where N<:Number
  put_ev = Put(con.env)
  con.put_queue[put_ev] = ContainerKey(priority, con.seid+=one(UInt), amount)
  @callback trigger_get(put_ev, con)
  trigger_put(put_ev, con)
  put_ev
end

request(res::Resource; priority::Int=0) = put(res, 1; priority=priority)

"""
  request_any(res_options::Vector{Resource}; priority::Int=0)

Request from a list of alternative resources.

The resource with the shortest queue is selected.
"""
function request_any(res_alts::Vector{Resource}; priority::Int=0)
  #find resource with the shortest put_queue
  _, res_id = findmin(length.([res.put_queue for res in res_alts]))
  #select the resource with the shortest put_queue
  res = res_alts[res_id]
  request(res; priority = priority)
end

function get(con::Container{N}, amount::N; priority::Int=0) where N<:Number
  get_ev = Get(con.env)
  con.get_queue[get_ev] = ContainerKey(priority, con.seid+=one(UInt), amount)
  @callback trigger_put(get_ev, con)
  trigger_get(get_ev, con)
  get_ev
end

release(res::Resource; priority::Int=0) = get(res, 1; priority=priority)

function do_put(con::Container{N}, put_ev::Put, key::ContainerKey{N}) where N<:Number
  con.level + key.amount > con.capacity && return false
  schedule(put_ev)
  con.level += key.amount
  true
end

function do_get(con::Container{N}, get_ev::Get, key::ContainerKey{N}) where N<:Number
  con.level - key.amount < zero(N) && return false
  schedule(get_ev)
  con.level -= key.amount
  true
end

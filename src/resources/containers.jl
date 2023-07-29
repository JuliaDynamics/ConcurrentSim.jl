struct ContainerKey{N<:Real, T<:Number} <: ResourceKey
  id :: UInt
  amount :: N
  priority :: T
end

mutable struct Container{N<:Real, T<:Number} <: AbstractResource
  env :: Environment
  capacity :: N
  level :: N
  seid :: UInt
  put_queue :: DataStructures.PriorityQueue{Put, ContainerKey{N, T}}
  get_queue :: DataStructures.PriorityQueue{Get, ContainerKey{N, T}}
  function Container{N, T}(env::Environment, capacity::N=one(N); level::N=zero(N)) where {N<:Real, T<:Number}
    new(env, capacity, level, zero(UInt), DataStructures.PriorityQueue{Put, ContainerKey{N, T}}(), DataStructures.PriorityQueue{Get, ContainerKey{N, T}}())
  end
end

function Container(env::Environment, capacity::N=one(N); level::N=zero(N)) where {N<:Real}
  Container{N, Int}(env, capacity, level=level)
end

const Resource = Container{Int, Int}

function put(con::Container{N, T}, amount::N; priority::T=zero(T)) where {N<:Real, T<:Number}
  put_ev = Put(con.env)
  con.put_queue[put_ev] = ContainerKey(con.seid+=one(UInt), amount, priority)
  @callback trigger_get(put_ev, con)
  trigger_put(put_ev, con)
  put_ev
end

request(res::Resource; priority::Number=0) = put(res, 1; priority=priority)

function get(con::Container{N, T}, amount::N; priority::T=zero(T)) where {N<:Real, T<:Number}
  get_ev = Get(con.env)
  con.get_queue[get_ev] = ContainerKey(con.seid+=one(UInt), amount, priority)
  @callback trigger_put(get_ev, con)
  trigger_get(get_ev, con)
  get_ev
end

release(res::Resource; priority::Number=0) = get(res, 1; priority=priority)

function do_put(con::Container{N, T}, put_ev::Put, key::ContainerKey{N, T}) where {N<:Real, T<:Number}
  con.level + key.amount > con.capacity && return false
  schedule(put_ev)
  con.level += key.amount
  true
end

function do_get(con::Container{N, T}, get_ev::Get, key::ContainerKey{N, T}) where {N<:Real, T<:Number}
  con.level - key.amount < zero(N) && return false
  schedule(get_ev)
  con.level -= key.amount
  true
end

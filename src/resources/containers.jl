struct ContainerKey{T<:Number, N<:Real} <: ResourceKey
  priority :: T
  id :: UInt
  amount :: N
end

mutable struct Container{T<:Number, N<:Real} <: AbstractResource
  env :: Environment
  capacity :: N
  level :: N
  seid :: UInt
  put_queue :: DataStructures.PriorityQueue{Put, ContainerKey{T, N}}
  get_queue :: DataStructures.PriorityQueue{Get, ContainerKey{T, N}}
  function Container{T, N}(env::Environment, capacity::N=one(N); level::N=zero(N)) where {T<:Number, N<:Real}
    new(env, capacity, level, zero(UInt), DataStructures.PriorityQueue{Put, ContainerKey{T, N}}(), DataStructures.PriorityQueue{Get, ContainerKey{T, N}}())
  end
end

function Container(env::Environment, capacity::N=one(N); level::N=zero(N)) where {N<:Real}
  Container{Int, N}(env, capacity, level=level)
end

const Resource = Container{Int, Int}

function put(con::Container{T, N}, amount::N; priority::Number=0) where {T<:Number, N<:Real}
  put_ev = Put(con.env)
  con.put_queue[put_ev] = ContainerKey(priority, con.seid+=one(UInt), amount)
  @callback trigger_get(put_ev, con)
  trigger_put(put_ev, con)
  put_ev
end

request(res::Resource; priority::Number=0) = put(res, 1; priority=priority)

function get(con::Container{T, N}, amount::N; priority::T=0) where {T<:Number, N<:Real}
  get_ev = Get(con.env)
  con.get_queue[get_ev] = ContainerKey(priority, con.seid+=one(UInt), amount)
  @callback trigger_put(get_ev, con)
  trigger_get(get_ev, con)
  get_ev
end

release(res::Resource; priority::Number=0) = get(res, 1; priority=priority)

function do_put(con::Container{T, N}, put_ev::Put, key::ContainerKey{T, N}) where {T<:Number, N<:Real}
  con.level + key.amount > con.capacity && return false
  schedule(put_ev)
  con.level += key.amount
  true
end

function do_get(con::Container{T, N}, get_ev::Get, key::ContainerKey{T, N}) where {T<:Number, N<:Real}
  con.level - key.amount < zero(N) && return false
  schedule(get_ev)
  con.level -= key.amount
  true
end

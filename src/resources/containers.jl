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

function Put(con::Container{N}, amount::N; priority::Int=0) where N<:Number
  put_ev = Put(con.env)
  con.put_queue[put_ev] = ContainerKey(priority, con.seid+=one(UInt), amount)
  @callback trigger_get(put_ev, con)
  trigger_put(put_ev, con)
  put_ev
end

const Request = Put

Request(res::Resource; priority::Int=0) = Put(res, 1; priority=priority)

function request(func::Function, res::Resource; priority::Int=0)
  req = Request(res; priority=priority)
  try
    func(req)
  finally
    if state(req) == triggered
      yield(Release(res; priority=priority))
    else
      cancel(res, req)
    end
  end
end

function Get(con::Container{N}, amount::N; priority::Int=0) where N<:Number
  get_ev = Get(con.env)
  con.get_queue[get_ev] = ContainerKey(priority, con.seid+=one(UInt), amount)
  @callback trigger_put(get_ev, con)
  trigger_get(get_ev, con)
  get_ev
end

const Release = Get

Release(res::Resource; priority::Int=0) = Get(res, 1; priority=priority)

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

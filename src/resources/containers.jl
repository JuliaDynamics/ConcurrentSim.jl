using Compat

struct ContainerKey{N<:Number} <: ResourceKey
  priority :: Int
  id :: UInt
  amount :: N
end

mutable struct Container{N<:Number, E<:Environment} <: AbstractResource{E}
  env :: E
  capacity :: N
  level :: N
  seid :: UInt
  Put_queue :: DataStructures.PriorityQueue{Put{E}, ContainerKey{N}}
  Get_queue :: DataStructures.PriorityQueue{Get{E}, ContainerKey{N}}
  function Container{N, E}(env::E, capacity::N, level::N) where {N<:Number, E<:Environment}
    new(env, capacity, level, zero(UInt), DataStructures.PriorityQueue(Put{E}, ContainerKey{N}), DataStructures.PriorityQueue(Get{E}, ContainerKey{N}))
  end
end

function Container{N<:Number, E<:Environment}(env::E, capacity::N; level::N=zero(N))
  Container{N, E}(env, capacity, level)
end

const Resource{E<:Environment} = Container{Int, E}

function Resource{E<:Environment}(env::E, capacity::Int=1; level::Int=0) :: Resource{E}
  Resource{E}(env, capacity, level)
end

function Put{N<:Number, E<:Environment}(con::Container{N, E}, amount::N; priority::Int=0) :: Put{E}
  put_ev = Put{E}(con.env)
  con.Put_queue[put_ev] = ContainerKey(priority, con.seid+=one(UInt), amount)
  append_callback(trigger_get, put_ev, con)
  trigger_put(put_ev, con)
  return put_ev
end

const Request = Put

Request{E<:Environment}(res::Resource{E}; priority::Int=0) = Put(res, 1, priority=priority)

macro Request(res, req, expr)
  esc(quote
    $req = Request($res)
    $expr
    if state($req) == SimJulia.triggered
      @yield return Release($res)
    else
      cancel($res, $req)
    end
  end)
end

function Request{E<:Environment}(func::Function, res::Resource{E}; priority::Int=0)
  req = Request(res, priority=priority)
  try
    func(req)
  finally
    if state(req) == triggered
      yield(Release(res, priority=priority))
    else
      cancel(res, req)
    end
  end
end

function Get{N<:Number, E<:Environment}(con::Container{N, E}, amount::N; priority::Int=0) :: Get{E}
  get_ev = Get{E}(con.env)
  con.Get_queue[get_ev] = ContainerKey(priority, con.seid+=one(UInt), amount)
  append_callback(trigger_put, get_ev, con)
  trigger_get(get_ev, con)
  return get_ev
end

const Release = Get

Release{E<:Environment}(res::Resource{E}; priority::Int=0) = Get(res, 1, priority=priority)

function do_put{N<:Number, E<:Environment}(con::Container{N, E}, put_ev::Put{E}, key::ContainerKey{N}) :: Bool
  if con.level + key.amount <= con.capacity
    schedule(put_ev.bev)
    con.level += key.amount
    return true
  end
  return false
end

function do_get{N<:Number, E<:Environment}(con::Container{N, E}, get_ev::Get{E}, key::ContainerKey{N}) :: Bool
  if con.level - key.amount >= zero(N)
    schedule(get_ev.bev)
    con.level -= key.amount
    return true
  end
  return false
end

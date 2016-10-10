type ContainerKey{N<:Number} <: ResourceKey
  priority :: Int
  id :: UInt
  amount :: N
end

type Container{N<:Number, E<:Environment} <: AbstractResource{E}
  env :: E
  capacity :: N
  level :: N
  seid :: UInt
  put_queue :: PriorityQueue{PutEvent{E}, ContainerKey{N}}
  get_queue :: PriorityQueue{GetEvent{E}, ContainerKey{N}}
  function Container(env::E, capacity::N, level::N)
    new(env, capacity, level, zero(UInt), PriorityQueue(PutEvent{E}, ContainerKey{N}), PriorityQueue(GetEvent{E}, ContainerKey{N}))
  end
end

function Container{N<:Number, E<:Environment}(env::E, capacity::N; level::N=zero(N)) :: Container{N, E}
  Container{N, E}(env, capacity, level)
end

typealias Resource{E<:Environment} Container{Int, E}

function Resource{E<:Environment}(env::E, capacity::Int=1; level::Int=0) :: Resource{E}
  Resource{E}(env, capacity, level)
end

function put{N<:Number, E<:Environment}(con::Container{N, E}, amount::N; priority::Int=0) :: PutEvent{E}
  put_ev = PutEvent(con.env)
  con.put_queue[put_ev] = ContainerKey(priority, con.seid+=one(UInt), amount)
  append_callback(trigger_get, put_ev, con)
  trigger_put(put_ev, con)
  return put_ev
end

request{E<:Environment}(res::Resource{E}; priority::Int=0) = put(res, 1, priority=priority)

function request{E<:Environment}(func::Function, res::Resource{E}; priority::Int=0)
  req = request(res, priority=priority)
  try
    func(req)
  finally
    if state(req) == processed
      yield(release(res, priority=priority))
    else
      cancel(res, req)
    end
  end
end

function get{N<:Number, E<:Environment}(con::Container{N, E}, amount::N; priority::Int=0) :: GetEvent{E}
  get_ev = GetEvent(con.env)
  con.get_queue[get_ev] = ContainerKey(priority, con.seid+=one(UInt), amount)
  append_callback(trigger_put, get_ev, con)
  trigger_get(get_ev, con)
  return get_ev
end

release{E<:Environment}(res::Resource{E}; priority::Int=0) = get(res, 1, priority=priority)

function do_put{N<:Number, E<:Environment}(con::Container{N, E}, put_ev::PutEvent{E}, key::ContainerKey{N}) :: Bool
  if con.level + key.amount <= con.capacity
    schedule(put_ev.bev)
    con.level += key.amount
    return true
  end
  return false
end

function do_get{N<:Number, E<:Environment}(con::Container{N, E}, get_ev::GetEvent{E}, key::ContainerKey{N}) :: Bool
  if con.level - key.amount >= zero(N)
    schedule(get_ev.bev)
    con.level -= key.amount
    return true
  end
  return false
end

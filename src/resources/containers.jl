struct ContainerKey{N<:Real, T<:Number} <: ResourceKey
  id :: UInt
  amount :: N
  priority :: T
end

"""
    Container{N}(env::Environment, capacity::N=one(N); level::N=zero(N))

A "Container" resource object, storing up to `capacity` units of a resource (of type `N`).

There is a `Resource` alias for `Container{Int}`.

`Resource()` with default capacity of `1` is very similar to a typical lock.
The [`request`](@ref) and [`unlock`](@ref) functions are a convenient way to interact with such a "lock",
in a way mostly compatible with other discrete event and concurrency frameworks.

See [`Store`](@ref) for a more channel-like resource.

Think of `Resource` and `Container` as locks and of `Store` as channels. They block only if empty (on taking) or full (on storing).
"""
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

function put!(con::Container{N, T}, amount::N; priority::T=zero(T)) where {N<:Real, T<:Number}
  put_ev = Put(con.env)
  con.put_queue[put_ev] = ContainerKey(con.seid+=one(UInt), amount, priority)
  @callback trigger_get(put_ev, con)
  trigger_put(put_ev, con)
  put_ev
end

"""
    request(res::Container)

Locks the Container (or Resources) and return the lock event.
If the capacity of the Container is greater than 1,
multiple requests can be made before blocking occurs.
"""
request(res::Resource; priority::Number=0) = put(res, 1; priority=priority)

"""
    tryrequest(res::Container)

If the Container (or Resource) is not locked, locks it and return the lock event.
Returns `false` if the Container is locked, similarly to the meaning of `trylock` for `Base.ReentrantLock`.

If the capacity of the Container is greater than 1,
multiple requests can be made before blocking occurs.

```jldoctest
julia> sim = Simulation(); res = Resource(sim);

julia> ev = tryrequest(res)
ConcurrentSim.Put 1

julia> typeof(ev)
ConcurrentSim.Put

julia> tryrequest(res)
false
```
"""
function tryrequest(res::Container; priority::Int=0)
    islocked(res) && return false # TODO check priority
    request(res; priority)
end

function get(con::Container{N, T}, amount::N; priority::T=zero(T)) where {N<:Real, T<:Number}
  get_ev = Get(con.env)
  con.get_queue[get_ev] = ContainerKey(con.seid+=one(UInt), amount, priority)
  @callback trigger_put(get_ev, con)
  trigger_get(get_ev, con)
  get_ev
end

"""
    unlock(res::Container)

Unlocks the Container and return the unlock event.
"""
unlock(res::Resource; priority::Number=0) = get(res, 1; priority=priority)

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

"""
    isready(::Container)

Returns `true` if the Container is not empty, similarly to the meaning of `isready` for `Base.Channel`.

```jldoctest
julia> sim = Simulation(); res = Resource(sim); isready(res)
false

julia> request(res); isready(res)
true
```
"""
isready(c::Container) = c.level > 0

"""
    islocked(::Container)

Returns `true` if the store is full, similarly to the meaning of `islocked` for `Base.ReentrantLock`.

```jldoctest
julia> sim = Simulation(); res = Resource(sim, 2); islocked(res)
false

julia> request(res); islocked(res)
false

julia> request(res); islocked(res)
true
```
"""
islocked(c::Container) = c.level==c.capacity

take!(::Container, args...) = error("There is no well defined `take!` for `Container`. Instead of attempting `take!` consider using `unlock(::Container)` or use a `Store` instead of a `Resource` or `Container`. Think of `Resource` and `Container` as locks and of `Store` as channels. They block only if empty (on taking) or full (on storing).")
lock(::Container) = error("Directly locking a `Container` is not implemented yet. Instead of attempting `lock`, consider using `@yield request(::Container)` from inside of a resumable function.")
trylock(::Container) = error("Directly locking a `Container` is not implemented yet. Instead of attempting `lock`, consider using `@yield request(::Container)` from inside of a resumable function.")

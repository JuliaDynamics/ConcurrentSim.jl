struct ContainerKey{N<:Real} <: ResourceKey
  priority :: Int
  id :: UInt
  amount :: N
end

"""
    Container{N}(env::Environment, capacity::N=one(N); level::N=zero(N))

A "Container" resource object, storing up to `capacity` units of a resource (of type `N`).

There is a `Resource` alias for `Container{Int}`.

`Resource()` with default capacity of `1` is very similar to a typical lock.
The [`lock`](@ref), [`unlock`](@ref), and [`trylock`](@ref) functions are a convenient way to interact with such a "lock",
in a way mostly compatible with other discrete event and concurrency frameworks.

See [`Store`](@ref) for a more channel-like resource.

Think of `Resource` and `Container` as locks and of `Store` as channels. They block only if empty (on taking) or full (on storing).
"""
mutable struct Container{N<:Real} <: AbstractResource
  env :: Environment
  capacity :: N
  level :: N
  seid :: UInt
  put_queue :: DataStructures.PriorityQueue{Put, ContainerKey{N}}
  get_queue :: DataStructures.PriorityQueue{Get, ContainerKey{N}}
  function Container{N}(env::Environment, capacity::N=one(N); level::N=zero(N)) where {N<:Real}
    new(env, capacity, level, zero(UInt), DataStructures.PriorityQueue{Put, ContainerKey{N}}(), DataStructures.PriorityQueue{Get, ContainerKey{N}}())
  end
end

function Container(env::Environment, capacity::N=one(N); level::N=zero(N)) where {N<:Real}
  Container{N}(env, capacity, level=level)
end

const Resource = Container{Int}

function put!(con::Container{N}, amount::N; priority::Int=0) where N<:Real
  put_ev = Put(con.env)
  con.put_queue[put_ev] = ContainerKey(priority, con.seid+=one(UInt), amount)
  @callback trigger_get(put_ev, con)
  trigger_put(put_ev, con)
  put_ev
end

"""
    lock(res::Container)

Locks the Container and return the lock event.
"""
lock(res::Container; priority::Int=0) = put!(res, 1; priority=priority)

"""
    trylock(res::Resource)

If the Resource is not locked, locks it and return the lock event.
Returns `false` if the Resource is locked, similarly to the meaning of `trylock` for `Base.ReentrantLock`.

```jldoctest
julia> sim = Simulation(); res = Resource(sim);

julia> ev = trylock(res)
ConcurrentSim.Put 1

julia> typeof(ev)
ConcurrentSim.Put

julia> trylock(res)
false
```
"""
function trylock(res::Container; priority::Int=0)
    islocked(res) && return false # TODO check priority
    lock(res; priority)
end

function get(con::Container{N}, amount::N; priority::Int=0) where N<:Real
  get_ev = Get(con.env)
  con.get_queue[get_ev] = ContainerKey(priority, con.seid+=one(UInt), amount)
  @callback trigger_put(get_ev, con)
  trigger_get(get_ev, con)
  get_ev
end

"""
    unlock(res::Container)

Unlocks the Container and return the unlock event.
"""
unlock(res::Container; priority::Int=0) = get(res, 1; priority=priority)

function do_put(con::Container{N}, put_ev::Put, key::ContainerKey{N}) where N<:Real
  con.level + key.amount > con.capacity && return false
  schedule(put_ev)
  con.level += key.amount
  true
end

function do_get(con::Container{N}, get_ev::Get, key::ContainerKey{N}) where N<:Real
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

julia> lock(res); isready(res)
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

julia> lock(res); islocked(res)
false

julia> lock(res); islocked(res)
true
```
"""
islocked(c::Container) = c.level==c.capacity

take!(::Container, args...) = error("There is no well defined `take!` for `Container`. Instead of attempting `take!` consider using `unlock(::Container)` or use a `Store` instead of a `Resource` or `Container`. Think of `Resource` and `Container` as locks and of `Store` as channels. They block only if empty (on taking) or full (on storing).")

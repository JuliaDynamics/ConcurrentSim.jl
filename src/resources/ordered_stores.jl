"""
    StackStore{N, T<:Number}

A store in which items are stored in a FILO order.

```jldoctest
julia> sim = Simulation()
       store = Store{Symbol}(sim)
       stack = StackStore{Symbol}(sim)
       items = [:a,:b,:a,:c];

julia> [put!(store, item) for item in items];

julia> [value(take!(store)) for _ in 1:length(items)]
4-element Vector{Symbol}:
 :a
 :a
 :b
 :c

julia> [put!(stack, item) for item in items];

julia> [value(take!(stack)) for _ in 1:length(items)]
4-element Vector{Symbol}:
 :c
 :a
 :b
 :a
```

See also: [`QueueStore`](@ref), [`Store`](@ref)
"""
const StackStore = Store{N, T, DataStructures.Stack{N}} where {N, T<:Number}
StackStore{N}(env::Environment; capacity=typemax(UInt), highpriofirst::Bool=false) where {N} = StackStore{N, Int}(env; capacity, highpriofirst=highpriofirst)

"""
    QueueStore{N, T<:Number}

A store in which items are stored in a FIFO order.

```jldoctest
julia> sim = Simulation()
       store = Store{Symbol}(sim)
       queue = QueueStore{Symbol}(sim)
       items = [:a,:b,:a,:c];

julia> [put!(store, item) for item in items];

julia> [value(take!(store)) for _ in 1:length(items)]
4-element Vector{Symbol}:
 :a
 :a
 :b
 :c

julia> [put!(queue, item) for item in items];

julia> [value(take!(queue)) for _ in 1:length(items)]
4-element Vector{Symbol}:
 :a
 :b
 :a
 :c
```

See also: [`StackStore`](@ref), [`Store`](@ref)
"""
const QueueStore = Store{N, T, DataStructures.Queue{N}} where {N, T<:Number}
QueueStore{N}(env::Environment; capacity=typemax(UInt), highpriofirst::Bool=false) where {N} = QueueStore{N, Int}(env; capacity, highpriofirst=highpriofirst)

function do_put(sto::StackStore{N, T}, put_ev::Put, key::StorePutKey{N, T}) where {N, T<:Number}
  if sto.load < sto.capacity
    sto.load += one(UInt)
    push!(sto.items, key.item)
    schedule(put_ev)
  end
  false
end

function do_get(sto::StackStore{N, T}, get_ev::Get, key::StoreGetKey{T}) where {N, T<:Number}
  key.filter !== get_any_item && error("Filtering not supported for `StackStore`. Use an unordered store instead, or submit a feature request for implementing filtering to our issue tracker.")
  isempty(sto.items) && return true
  item = pop!(sto.items)
  sto.load -= one(UInt)
  schedule(get_ev; value=item)
  true
end

function do_put(sto::QueueStore{N, T}, put_ev::Put, key::StorePutKey{N, T}) where {N, T<:Number}
  if sto.load < sto.capacity
    sto.load += one(UInt)
    enqueue!(sto.items, key.item)
    schedule(put_ev)
  end
  false
end

function do_get(sto::QueueStore{N, T}, get_ev::Get, key::StoreGetKey{T}) where {N, T<:Number}
  key.filter !== get_any_item && error("Filtering not supported for `QueueStore`. Use an unordered store instead, or submit a feature request for implementing filtering to our issue tracker.")
  isempty(sto.items) && return true
  item = dequeue!(sto.items)
  sto.load -= one(UInt)
  schedule(get_ev; value=item)
  true
end

import Tables

"""
A wrapper around a resource that tracks the time at which the resource is interacted with.

```jldoctest
julia> using ConcurrentSim, DataFrames

julia> env = Simulation(); r = TrackedResource(Resource(env));

julia> run(env, 1); now(env)
1.0

julia> request(r); run(env, 2); now(env)
2.0

julia> request(r); run(env, 3); unlock(r); run(env, 4); now(env)
4.0

julia> DataFrame(r)
3×2 DataFrame
 Row │ events    times
     │ Symbol    Float64
─────┼───────────────────
   1 │ increase      1.0
   2 │ increase      2.0
   3 │ decrease      3.0
```
"""
struct TrackedResource{T}
    resource::T
    events::Vector{Symbol}
    times::Vector{Float64}
end

TrackedResource(resource) = TrackedResource(resource, Symbol[], Float64[])

function Base.take!(tr::TrackedResource, args...; kwargs...)
    r = take!(tr.resource, args...; kwargs...)
    push!(tr.events, :decrease)
    push!(tr.times, now(tr.resource.env))
    return r
end

function Base.put!(tr::TrackedResource, args...; kwargs...)
    r = put!(tr.resource, args...; kwargs...)
    push!(tr.events, :increase)
    push!(tr.times, now(tr.resource.env))
    return r
end

function Base.unlock(tr::TrackedResource, args...; kwargs...)
    r = unlock(tr.resource, args...; kwargs...)
    push!(tr.events, :decrease)
    push!(tr.times, now(tr.resource.env))
    return r
end

function request(tr::TrackedResource, args...; kwargs...)
    r = request(tr.resource, args...; kwargs...)
    push!(tr.events, :increase)
    push!(tr.times, now(tr.resource.env))
    return r
end

##
# Tables interface
##

Tables.istable(::Type{<:TrackedResource}) = true
Tables.schema(tr::TrackedResource) = Tables.Schema(Tables.columnnames(tr), [Symbol, Float64])

Tables.columnaccess(::Type{<:TrackedResource}) = true

Tables.columns(tr::TrackedResource) = tr

function Tables.getcolumn(tr::TrackedResource, i::Int)
    if i == 1
        return tr.events
    elseif i == 2
        return tr.times
    else
        error("`TrackedResource` has only two columns, but you are attempting to access column $(i).")
    end
end

function Tables.getcolumn(tr::TrackedResource, s::Symbol)
    if s == :events
        return tr.events
    elseif s == :times
        return tr.times
    else
        error("`TrackedResource` has only two columns (events and times), but you are attempting to access column $(s).")
    end
end

function Tables.columnnames(tr::TrackedResource)
    return (:events, :times)
end

# TODO Makie recipes

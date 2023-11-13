@doc raw"""
    DelayQueue{T}

A queue in which items are stored in a FIFO order, but are only available after a delay.

```jldoctest
julia> sim = Simulation()
       queue = DelayQueue{Symbol}(sim, 10)
       @resumable function producer(env, queue)
           for item in [:a,:b,:a,:c]
               @info "putting $item at time $(now(env))"
               put!(queue, item)
               @yield timeout(env, 2)
           end
       end
       @resumable function consumer(env, queue)
           @yield timeout(env, 5)
           while true
               t = @yield take!(queue)
               @info "taking $(t) at time $(now(env))"
           end
       end
       @process producer(sim, queue)
       @process consumer(sim, queue)
       run(sim, 30)
[ Info: putting a at time 0.0
[ Info: putting b at time 2.0
[ Info: putting a at time 4.0
[ Info: putting c at time 6.0
[ Info: taking a at time 10.0
[ Info: taking b at time 12.0
[ Info: taking a at time 14.0
[ Info: taking c at time 16.0
```
"""
mutable struct DelayQueue{T}
    store::QueueStore{T, Int}
    delay::Float64
end
function DelayQueue(env::Environment, delay; highpriofirst::Bool=false)
    return DelayQueue(QueueStore{Any}(env, highpriofirst=highpriofirst), float(delay))
end
function DelayQueue{T}(env::Environment, delay; highpriofirst::Bool=false) where T
    return DelayQueue(QueueStore{T}(env, highpriofirst=highpriofirst), float(delay))
end

@resumable function latency(env::Environment, channel::DelayQueue, value)
    @yield timeout(channel.store.env, channel.delay)
    put!(channel.store, value)
end

function Base.put!(channel::DelayQueue, value)
    @process latency(channel.store.env, channel, value) # start the process, but do not wait on it
end

function Base.take!(channel::DelayQueue)
    get(channel.store)
end

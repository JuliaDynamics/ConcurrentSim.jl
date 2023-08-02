Base.@deprecate put(args...) put!(args...)
#Base.@deprecate request(args...; kwargs...) lock(args...; kwargs...) # Not the same: `request` needs to be yielded, while `lock` yields itself
#Base.@deprecate tryrequest(args...; kwargs...) trylock(args...; kwargs...) # Not the same: `request` needs to be yielded, while `lock` yields itself
Base.@deprecate release(args...; kwargs...) unlock(args...; kwargs...)

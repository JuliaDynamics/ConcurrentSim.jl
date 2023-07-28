Base.@deprecate put(args...) put!(args...)
Base.@deprecate request(args...; kwargs...) lock(args...; kwargs...)

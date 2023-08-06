Base.@deprecate put(args...; kwargs...) put!(args...; kwargs...)
const request = lock
const tryrequest = trylock
const release = unlock

# API

```@autodocs
Modules = [ConcurrentSim]
Private = false
```

```@docs
lock(res::Container; priority::Int=0)
unlock(res::Container; priority::Int=0)
trylock(res::Container; priority::Int=0)
take!(sto::Store, filter::Function=get_any_item; priority::Int=0)
```
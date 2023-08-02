# API

```@autodocs
Modules = [ConcurrentSim]
Private = false
```

```@docs
unlock(res::Container; priority::Int=0)
take!(sto::Store, filter::Function=get_any_item; priority::Int=0)
```
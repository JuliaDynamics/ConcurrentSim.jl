# API

```@autodocs
Modules = [ConcurrentSim]
Private = false
```

```@docs
lock(res::Resource; priority=0)
unlock(res::Resource; priority=0)
take!(sto::Store, filter::Function=get_any_item; priority=0)
```
# Blocking and Yielding Resource API

The goal of this page is to list the most common synchronization and resource management patterns used in `ConcurrentSim.jl` simulations and to briefly compare them to Julia's base capabilities for asynchronous and parallel programming.

There are many different approaches to discrete event simulation in particular and to asynchronous and parallel programming in general. This page assumes some rudimentary understanding of concurrency in programming. While not necessary, you are encouraged to explore the following resources for a more holistic understanding:

- "concurrency" vs "parallelism" - see [stackoverflow.com](https://stackoverflow.com/questions/1050222/what-is-the-difference-between-concurrency-and-parallelism) on the topic;
- "threads" vs "tasks": A task is the actual piece of work, a thread is the "runway" on which a task runs. You can have more tasks than threads and you can even have tasks that jump between threads - see Julia's [parallel programming documentation](https://docs.julialang.org/en/v1/manual/parallel-computing/) (in particular the [async](https://docs.julialang.org/en/v1/manual/asynchronous-programming/) and [multithreading](https://docs.julialang.org/en/v1/manual/multi-threading/) docs), and multiple Julia blog post on [multithreading](https://julialang.org/blog/2019/07/multithreading/) and [its misuses](https://julialang.org/blog/2023/07/PSA-dont-use-threadid/);
- "locks" used to guard (or synchronize) the access to a given resource: i.e. one threads locks an array while modifying it in order to ensure that another thread will not be modifying it at the same time. Julia's `Base` multithreading capabilities provide a `ReentrantLock`, together with a `lock`, `trylock`, `unlock`, and `islocked` API;
- "channels" used to organize concurrent tasks. Julia's `Base` multithreading capabilities provide `Channel`, together with `take!`, `put!`, `isready`;
- knowing of the ["red/blue-colored functions" metaphor](https://journal.stuffwithstuff.com/2015/02/01/what-color-is-your-function/) can be valuable as well as learning of "promises" and "futures".

Programming discrete event simulations can be very similar to async parallel programming, except for the fact that in the simulation the "time" is fictitious (and tracking it is a big part of the value proposition in the simulation software). On the other hand, in usual parallel programming the goal is simply to do as much work as possible in the shortest (actual) time. In that context, one possible use of discrete event simulations is to cheaply model and optimize various parallel implementations of actual expensive algorithms (whether numerical computer algorithms or the algorithms used to schedule a real factory or a fleet of trucks).

In particular, the `ConcurrentSim.jl` package uses the async "coroutines" model of parallel programing. `ConcurrentSim` uses the `ResumableFunctions.jl` package to build its coroutines, which uses the `@resumable` macro to mark a function as an "async" coroutine and the `@yield` macro to yield between coroutines.

!!! warning "Base Julia coroutines vs ConcurrentSim coroutines"
    The `ConcurrentSim` and `ResumableFunctions` coroutines are currently incompatible with Julia's base coroutines (which based around `wait` and `fetch`). A separate coroutines implementation was necessary, because Julia's coroutines are designed for computationally heavy tasks and practical parallel algorithms, leading to significant overhead when they are used with extremely large numbers of computationally cheap tasks, as it is common in discrete event simulators. `ResumableFunctions`'s coroutines are single threaded but with drastically lower call overhead.
    A future long-term goal of ours is to unify the API used by `ResumableFunctions` and base Julia, but this will not be achieved in the near term, hence the need for pages like this one.

Without further ado, here is the typical API used with:

- `ConcurrentSim.Resource` which is used to represent scarce resource that can be used by only up to a fixed number of tasks. If the limit is just one task (the default), this is very similar to `Base.ReentrantLock`. `Resource` is a special case of `Container` with an integer "resource counter".
- `ConcurrentSim.Store` which is used to represent a FILO stack.

```@raw html
<div style="width:120%;min-width:120%;">
```

||`Base` `ReentrantLock`|`Base` `Channel`|`ConcurrentSim` `Container`|`ConcurrentSim` `Resource`, i.e. `Container{Int}`|`ConcurrentSim` `Store`||
|---|:---|:---|:---|:---|:---|:---:|
|`put!`|❌|❌|@yield|@yield|@yield|low-level "put an object in" API|
|`take!`|❌|block|❌|❌|@yield|the `Channel`-like API for `Store`|
|`lock`|block|❌|@yield|@yield|❌|the `Lock`-like API for `Resource` (there is also `trylock`)|
|`unlock`|✔️|❌|@yield|@yield|❌|the `Lock`-like API for `Resource`|
|`isready`|❌|✔️|✔️|✔️|✔️|something is stored in the resource|
|`islocked`|✔️|❌|✔️|✔️|✔️|the resource can not store anything more|

```@raw html
</div>
```

The table denotes which methods exist (✔️), are blocking (block), need to be explicitly yielded with `ResumableFunctions` (@yield), or are not applicable (❌).

As you can see `Resource` shares some properties with `ReentrantLock` and avails itself of the `lock`/`unlock`/`trylock` Base API. `Store` similarly shares some properties with `Channel` and shares the `put!`/`take!` Base API. Of note is that when the Base API would be blocking, the corresponding `ConcurrentSim` methods actually give coroutines that need to be `@yield`-ed.

`take` and `lock` are both implemented on top of the lower level `get`.

The `Base.lock` and `Base.unlock` are aliased to `ConcurrentSim.request` and `ConcurrentSim.release` respectively for semantic convenience when working with `Resource`. 
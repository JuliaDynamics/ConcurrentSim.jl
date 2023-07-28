# Environments

A simulation environment manages the simulation time as well as the scheduling and processing of events. It also provides means to step through or execute the simulation.

The base type for all environments is `Environment`. “Normal” simulations use its subtype `Simulation`.

## Simulation control

ConcurrentSim is very flexible in terms of simulation execution. You can run your simulation until there are no more events, until a certain simulation time is reached, or until a certain event is triggered. You can also step through the simulation event by event. Furthermore, you can mix these things as you like.

For example, you could run your simulation until an interesting event occurs. You could then step through the simulation event by event for a while; and finally run the simulation until there are no more events left and your processes have all terminated.

The most important function here is `run`:

- If you call it with an instance of the environment as the only argument  (`run(env)`), it steps through the simulation until there are no more events left. If your processes run forever, this function will never terminate (unless you kill your script by e.g., pressing `Ctrl-C`).

- In most cases it is advisable to stop your simulation when it reaches a certain simulation time. Therefore, you can pass the desired time via a second argument, e.g.: `run(env, 10)`.

  The simulation will then stop when the internal clock reaches 10 but will not process any events scheduled for time 10. This is similar to a new environment where the clock is 0 but (obviously) no events have yet been processed.

  If you want to integrate your simulation in a GUI and want to draw a process bar, you can repeatedly call this function with increasing until values and update your progress bar after each call:

```julia
sim = Simulation()
for t in 1:100
  run(sim, t)
  update(progressbar, t)
end
```

- Instead of passing a number as second argument to `run`, you can also pass any event to it. `run` will then return when the event has been processed.

  Assuming that the current time is 0, `run(env, timeout(env, 5))` is equivalent to `run(env, 5)`.

  You can also pass other types of events (remember, that a `Process` is an event, too):

```jldoctest
using ResumableFunctions
using ConcurrentSim

@resumable function my_process(env::Environment)
  @yield timeout(env, 1)
  "Monty Python's Flying Circus"
end

sim = Simulation()
proc = @process my_process(sim)
run(sim, proc)

# output

"Monty Python's Flying Circus"
```

To step through the simulation event by event, the environment offers `step`. This function processes the next scheduled event. It raises an `EmptySchedule` exception if no event is available.

In a typical use case, you use this function in a loop like:
```julia
while now(sim) < 10
  step(sim)
end
```

## State access

The environment allows you to get the current simulation time via the function `now`. The simulation time is a number without unit and is increased via `timeout` events.

By default, the simulation starts at time 0, but you can pass an `initial_time` to the `Simulation` constructor to use something else.

Note

!!! note
    Although the simulation time is technically unitless, you can pretend that it is, for example, in milliseconds and use it like a timestamp returned by `Base.Dates.datetime2epochm` to calculate a date or the day of the week. The `Simulation` constructor and the `run` function accept as argument a `Base.Dates.DateTime` and the `timeout` constructor a `Base.Dates.Delay`. Together with the convenience function `nowDateTime` a simulation can transparantly schedule its events in seconds, minutes, hours, days, ...

The function `active_process` is comparable to `Base.Libc.getpid` and returns the current active `Process`. If no process is active, a `NullException` is thrown. A process is active when its process function is being executed. It becomes inactive (or suspended) when it yields an event.

Thus, it only makes sense to call this function from within a process function or a function that is called by your process function:

```jldoctest
julia> using ResumableFunctions

julia> using ConcurrentSim

julia> function subfunc(env::Environment)
         println(active_process(env))
       end
subfunc (generic function with 1 method)

julia> @resumable function my_proc(env::Environment)
         while true
           println(active_process(env))
           subfunc(env)
           @yield timeout(env, 1)
         end
       end
my_proc (generic function with 1 method)

julia> sim = Simulation()
ConcurrentSim.Simulation time: 0.0 active_process: nothing

julia> @process my_proc(sim)
ConcurrentSim.Process 1

julia> isnothing(active_process(sim))
true

julia> ConcurrentSim.step(sim)
ConcurrentSim.Process 1
ConcurrentSim.Process 1

julia> isnothing(active_process(sim))
true
```

An exemplary use case for this is the resource system: If a process function calls `lock` to request a `Resource`, the resource determines the requesting process via `active_process`.

## Miscellaneous

A generator function can have a return value:

```julia
@resumable function my_proc(env::Environment)
  @yield timeout(sim, 1)
  150
end
```

In ConcurrentSim, this can be used to provide return values for processes that can be used by other processes:

```julia
@resumable function other_proc(env::Environment)
  ret_val = @yield @process my_proc(env)
  @assert ret_val == 150
end
```
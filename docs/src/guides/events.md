# Events

ConcurrentSim includes an extensive set of event types for various purposes. All of them are descendants of `AbstractEvent`. Here the following events are discussed:

- `Event`
- `timeout`
- `Operator`

The guide to resources describes the various resource events.

## Event basics

ConcurrentSim events are very similar – if not identical — to deferreds, futures or promises. Instances of the type AbstractEvent are used to describe any kind of events. Events can be in one of the following states. An event:

- might happen (idle),
- is going to happen (scheduled) or
- has happened (processed).

They traverse these states exactly once in that order. Events are also tightly bound to time and time causes events to advance their state.

Initially, events are idle and the function `state` returns `ConcurrentSim.idle`.

If an event gets scheduled at a given time, it is inserted into ConcurrentSim’s event queue. The function `state` returns `ConcurrentSim.scheduled`.

As long as the event is not processed, you can add callbacks to an event. Callbacks are function having an `AbstractEvent` as first parameter.

An event becomes processed when ConcurrentSim pops it from the event queue and calls all of its callbacks. It is now no longer possible to add callbacks. The function `state` returns `ConcurrentSim.processed`.

Events also have a value. The value can be set before or when the event is scheduled and can be retrieved via the function `value` or, within a process, by yielding the event (`value = @yield event`).

## Adding callbacks to an event

“What? Callbacks? I’ve never seen no callbacks!”, you might think if you have worked your way through the tutorial.

That’s on purpose. The most common way to add a callback to an event is yielding it from your process function (`@yield event`). This will add the process’ `resume` function as a callback. That’s how your process gets resumed when it yielded an event.

However, you can add any function to the list of callbacks as long as it accepts `AbstractEvent` or a descendant as first parameter:

```jldoctest
julia> using ConcurrentSim

julia> function my_callback(ev::AbstractEvent)
         println("Called back from ", ev)
       end
my_callback (generic function with 1 method)

julia> sim = Simulation()
ConcurrentSim.Simulation time: 0.0 active_process: nothing

julia> ev = Event(sim)
ConcurrentSim.Event 1

julia> @callback my_callback(ev)
(::#3) (generic function with 1 method)

julia> succeed(ev)
ConcurrentSim.Event 1

julia> run(sim)
Called back from ConcurrentSim.Event 1
```
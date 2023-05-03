# Simulvent basics

This guide describes the basic concepts of Simulvent: How does it work? What are processes, events and the environment? What can I do with them?

## How Simulvent works

If you break Simulvent down, it is just an asynchronous event dispatcher. You generate events and schedule them at a given simulation time. Events are sorted by priority, simulation time, and an increasing event id. An event also has a list of callbacks, which are executed when the event is triggered and processed by the event loop. Events may also have a return value.

The components involved in this are the `Environment`, events and the process functions that you write.

Process functions implement your simulation model, that is, they define the behavior of your simulation. They are `@resumable` functions that `@yield` instances of `AbstractEvent`.

The environment stores these events in its event list and keeps track of the current simulation time.

If a process function yields an event, Simulvent adds the process to the event’s callbacks and suspends the process until the event is triggered and processed. When a process waiting for an event is resumed, it will also receive the event’s value.

Here is a very simple example that illustrates all this:

```jldoctest
using Semicoroutines
using Simulvent

@resumable function example(env::Environment)
  event = timeout(env, 1, value=42)
  value = @yield event
  println("now=", now(env), ", value=", value)
end

sim = Simulation()
@process example(sim)
run(sim)

# output

now=1.0, value=42
```

The `example` process function above first creates a `timeout` event. It passes the environment, a delay, and a value to it. The `timeout` schedules itself at `now + delay` (that’s why the environment is required); other event types usually schedule themselves at the current simulation time.

The process function then yields the event and thus gets suspended. It is resumed, when Simulvent processes the `timeout` event. The process function also receives the event’s value (42) – this is, however, optional, so `@yield event` would have been okay if the you were not interested in the value or if the event had no value at all.

Finally, the process function prints the current simulation time (that is accessible via the `now` function) and the `timeout`’s value.

If all required process functions are defined, you can instantiate all objects for your simulation. In most cases, you start by creating an instance of `Environment`, e.g. a `Simulation`, because you’ll need to pass it around a lot when creating everything else.

Starting a process function involves two things:

- You have to call the macro `@process` with as argument a call to the process function. (This will not execute any code of that function yet.) This will schedule an initialisation event at the current simulation time which starts the execution of the process function. The process instance is also an event that is triggered when the process function returns.
- Finally, you can start Simulvent’s event loop. By default, it will run as long as there are events in the event list, but you can also let it stop earlier by providing an until argument.
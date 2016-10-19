# Basic Concepts

SimJulia is a discrete-event simulation library. The behavior of active components (like vehicles, customers or messages) is modeled with **Processes**. All processes live in an **Environment**, e.g. a **Simulation**. They interact with the environment and with each other via **Events**.

Processes are described by simple Julia functions. During their lifetime, they create events and **yield** them in order to wait for them to be triggered.

When a process yields an event, the process gets suspended. SimJulia resumes the process, when the event occurs (we say that the event is triggered). Multiple processes can wait for the same event. SimJulia resumes them in the same order in which they yielded that event.

An important event is a **Timeout**. Events of this type are triggered after a certain amount of (simulated) time has passed. They allow a process to sleep (or hold its state) for the given time. A Timeout and all other events can be created by calling an appropriate function having a reference to the environment that the process lives in.

## The First Process

The first example will be a *car* process. The car will alternately drive and park for a while. When it starts driving (or parking), it will print the current simulation time.

So let’s start:

```@example
using SimJulia

function car(sim::Simulation)
  while true
    println("Start parking at $(now(sim))")
    parking_duration = 5
    yield(Timeout(sim, parking_duration))
    println("Start driving at $(now(sim))")
    trip_duration = 2
    yield(Timeout(sim, trip_duration))
  end
end
```

The car process function requires a reference to an [`Simulation`](@ref) in order to create new events. The car‘s behavior is described in an infinite loop. Though it will never terminate, it will pass the control flow back to the simulation once a [`yield`](@ref) statement is reached. If the yielded event is triggered (“it occurs”), the simulation will resume the function at this statement.

The car switches between the states parking and driving. It announces its new state by printing a message and the current simulation time (as returned by the function [`now`](@ref). It then calls the functions [`Timeout`](@ref) to create a Timeout event. This event describes the point in time the car is done parking (or driving, respectively). By yielding the event, it signals the simulation that it wants to wait for the event to occur.

Now that the behavior of the car has been modeled, we create an instance of it and see how it behaves:

```@setup 10_min_2
using SimJulia
function car(sim::Simulation)
  while true
    println("Start parking at $(now(sim))")
    parking_duration = 5
    yield(Timeout(sim, parking_duration))
    println("Start driving at $(now(sim))")
    trip_duration = 2
    yield(Timeout(sim, trip_duration))
  end
end
```

```@example 10_min_2
sim = Simulation()
Process(car, sim)
run(sim, 15)
```

The first thing to do is to create an instance of class [`Simulation`](@ref). This instance is passed into the `car` process function.

Calling the constructor [`Process`](@ref) creates a process that is started immediately and is added to the environment. Note, that at this time, none of the code of our process function is being executed. Its execution is merely scheduled at the current simulation time.

Finally, the simulation starts by calling [`run`](@ref) where the second argument is the end time.

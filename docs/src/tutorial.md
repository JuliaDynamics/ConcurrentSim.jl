# Tutorial

## Basic Concepts

Simjulia is a discrete-event simulation library. The behavior of active components (like vehicles, customers or messages) is modeled with processes. All processes live in an environment. They interact with the environment and with each other via events.

Processes are described by `@resumable` functions. You can call them process function. During their lifetime, they create events and `@yield` them in order to wait for them to be triggered.

!!! note
    Detailed information about the `@resumable` and the `@yield` macros can be found in the documentation of [ResumableFunctions](https://github.com/JuliaDynamics/ResumableFunctions.jl.git).

When a process yields an event, the process gets suspended. ConcurrentSim resumes the process, when the event occurs (we say that the event is triggered). Multiple processes can wait for the same event. ConcurrentSim resumes them in the same order in which they yielded that event.

An important event type is the `timeout`. Events of this type are scheduled after a certain amount of (simulated) time has passed. They allow a process to sleep (or hold its state) for the given time. A `timeout` and all other events can be created by calling a constructor having the environment as first argument.

## Our First Process

Our first example will be a car process. The car will alternately drive and park for a while. When it starts driving (or parking), it will print the current simulation time.

So let’s start:

```jldoctest
julia> using ResumableFunctions

julia> using ConcurrentSim

julia> @resumable function car(env::Environment)
           while true
             println("Start parking at ", now(env))
             parking_duration = 5
             @yield timeout(env, parking_duration)
             println("Start driving at ", now(env))
             trip_duration = 2
             @yield timeout(env, trip_duration)
           end
         end
car (generic function with 1 method)
```

Our car process requires a reference to an `Environment` in order to create new events. The car‘s behavior is described in an infinite loop. Remember, the `car` function is a `@resumable` function. Though it will never terminate, it will pass the control flow back to the simulation once a `@yield` statement is reached. Once the yielded event is triggered (“it occurs”), the simulation will resume the function at this statement.

As said before, our car switches between the states parking and driving. It announces its new state by printing a message and the current simulation time (as returned by the function call `now`). It then calls the constructor `timeout` to create a timeout event. This event describes the point in time the car is done parking (or driving, respectively). By yielding the event, it signals the simulation that it wants to wait for the event to occur.

Now that the behavior of our car has been modeled, lets create an instance of it and see how it behaves:

```@meta
DocTestSetup = quote
  using ResumableFunctions
  using ConcurrentSim

  @resumable function car(env::Environment)
    while true
      println("Start parking at ", now(env))
      parking_duration = 5
      @yield timeout(env, parking_duration)
      println("Start driving at ", now(env))
      trip_duration = 2
      @yield timeout(env, trip_duration)
    end
  end
end
```

```jldoctest
julia> sim = Simulation()
ConcurrentSim.Simulation time: 0.0 active_process: nothing

julia> @process car(sim)
ConcurrentSim.Process 1

julia> run(sim, 15)
Start parking at 0.0
Start driving at 5.0
Start parking at 7.0
Start driving at 12.0
Start parking at 14.0
```

```@meta
DocTestSetup = nothing
```

The first thing we need to do is to create an environment, e.g. an instance of `Simulation`. The macro `@process` having as argument a car process function call creates a process that is initialised and added to the environment automatically.

Note, that at this time, none of the code of our process function is being executed. Its execution is merely scheduled at the current simulation time.

The `Process` returned by the `@process` macro can be used for process interactions.

Finally, we start the simulation by calling `run` and passing an end time to it.

## Process Interaction

The `Process` instance that is returned by `@process` macro can be utilized for process interactions. The two most common examples for this are to wait for another process to finish and to interrupt another process while it is waiting for an event.

### Waiting for a Process

As it happens, a ConcurrentSim `Process` can be used like an event. If you yield it, you are resumed once the process has finished. Imagine a car-wash simulation where cars enter the car-wash and wait for the washing process to finish, or an airport simulation where passengers have to wait until a security check finishes.

Lets assume that the car from our last example is an electric vehicle. Electric vehicles usually take a lot of time charging their batteries after a trip. They have to wait until their battery is charged before they can start driving again.

We can model this with an additional charge process for our car. Therefore, we redefine our `car` process function and add a `charge` process function.

A new charge process is started every time the vehicle starts parking. By yielding the `Process` instance that the `@process` macro returns, the `run` process starts waiting for it to finish:

```jldoctest
julia> using ResumableFunctions

julia> using ConcurrentSim

julia> @resumable function charge(env::Environment, duration::Number)
         @yield timeout(env, duration)
       end
charge (generic function with 1 method)

julia> @resumable function car(env::Environment)
         while true
           println("Start parking and charging at ", now(env))
           charge_duration = 5
           charge_process = @process charge(sim, charge_duration)
           @yield charge_process
           println("Start driving at ", now(env))
           trip_duration = 2
           @yield timeout(sim, trip_duration)
         end
       end
car (generic function with 1 method)
```

```@meta
DocTestSetup = quote
  using ResumableFunctions

  using ConcurrentSim

  @resumable function charge(env::Environment, duration::Number)
    @yield timeout(env, duration)
  end

  @resumable function car(env::Environment)
    while true
      println("Start parking and charging at ", now(env))
      charge_duration = 5
      charge_process = @process charge(sim, charge_duration)
      @yield charge_process
      println("Start driving at ", now(env))
      trip_duration = 2
      @yield timeout(sim, trip_duration)
    end
  end
end
```

Starting the simulation is straightforward again: We create a `Simulation`, one (or more) cars and finally call `run`.

```jldoctest
julia> sim = Simulation()
ConcurrentSim.Simulation time: 0.0 active_process: nothing

julia> @process car(sim)
ConcurrentSim.Process 1

julia> run(sim, 15)
Start parking and charging at 0.0
Start driving at 5.0
Start parking and charging at 7.0
Start driving at 12.0
Start parking and charging at 14.0
```

```@meta
DocTestSetup = nothing
```

### Interrupting Another Process

Imagine, you don’t want to wait until your electric vehicle is fully charged but want to interrupt the charging process and just start driving instead.

ConcurrentSim allows you to interrupt a running process by calling the `interrupt` function:

```jldoctest
julia> using ResumableFunctions

julia> using ConcurrentSim

julia> @resumable function driver(env::Environment, car_process::Process)
         @yield timeout(env, 3)
         @yield interrupt(car_process)
       end
driver (generic function with 1 method)
```

The driver process has a reference to the car process. After waiting for 3 time steps, it interrupts that process.

Interrupts are thrown into process functions as `Interrupt` exceptions that can (should) be handled by the interrupted process. The process can then decide what to do next (e.g., continuing to wait for the original event or yielding a new event):

```@meta
DocTestSetup = quote
  using ResumableFunctions
  using ConcurrentSim
end
```

```jldoctest
julia> @resumable function charge(env::Environment, duration::Number)
         @yield timeout(env, duration)
       end
charge (generic function with 1 method)

julia> @resumable function car(env::Environment)
         while true
           println("Start parking and charging at ", now(env))
           charge_duration = 5
           charge_process = @process charge(sim, charge_duration)
           try
             @yield charge_process
           catch
             println("Was interrupted. Hopefully, the battery is full enough ...")
           end
           println("Start driving at ", now(env))
           trip_duration = 2
           @yield timeout(sim, trip_duration)
         end
       end
car (generic function with 1 method)
```

When you compare the output of this simulation with the previous example, you’ll notice that the car now starts driving at time 3 instead of 5:

```@meta
DocTestSetup = quote
  using ResumableFunctions
  using ConcurrentSim

  @resumable function driver(env::Environment, car_process::Process)
    @yield timeout(env, 3)
    @yield interrupt(car_process)
  end

  @resumable function charge(env::Environment, duration::Number)
    @yield timeout(env, duration)
  end

  @resumable function car(env::Environment)
    while true
      println("Start parking and charging at ", now(env))
      charge_duration = 5
      charge_process = @process charge(sim, charge_duration)
      try
        @yield charge_process
      catch
        println("Was interrupted. Hopefully, the battery is full enough ...")
      end
      println("Start driving at ", now(env))
      trip_duration = 2
      @yield timeout(sim, trip_duration)
    end
  end
end
```

```jldoctest
julia> sim = Simulation()
ConcurrentSim.Simulation time: 0.0 active_process: nothing

julia> car_process = @process car(sim)
ConcurrentSim.Process 1

julia> @process driver(sim, car_process)
ConcurrentSim.Process 3

julia> run(sim, 15)
Start parking and charging at 0.0
Was interrupted. Hopefully, the battery is full enough ...
Start driving at 3.0
Start parking and charging at 5.0
Start driving at 10.0
Start parking and charging at 12.0
```

```@meta
DocTestSetup = nothing
```

## Shared Resources

ConcurrentSim offers three types of resources that help you modeling problems, where multiple processes want to use a resource of limited capacity (e.g., cars at a fuel station with a limited number of fuel pumps) or classical producer-consumer problems.

In this section, we’ll briefly introduce ConcurrentSim’s `Resource` class.

### Basic Resource Usage

We’ll slightly modify our electric vehicle process `car` that we introduced in the last sections.

The car will now drive to a battery charging station (BCS) and request (lock) one of its two charging spots. If both of these spots are currently in use, it waits until one of them becomes available again. It then starts charging its battery and leaves the station afterwards:

```jldoctest
julia> using ResumableFunctions

julia> using ConcurrentSim

julia> @resumable function car(env::Environment, name::Int, bcs::Resource, driving_time::Number, charge_duration::Number)
         @yield timeout(sim, driving_time)
         println(name, " arriving at ", now(env))
         @yield lock(bcs)
         println(name, " starting to charge at ", now(env))
         @yield timeout(sim, charge_duration)
         println(name, " leaving the bcs at ", now(env))
         @yield release(bcs)
       end
car (generic function with 1 method)
```

The resource’s `lock` function generates an event that lets you wait until the resource becomes available again. If you are resumed, you “own” the resource until you release it.

You are responsible to call `release` once you are done using the resource. When you release a resource, the next waiting process is resumed and now “owns” one of the resource’s slots. The basic `Resource` sorts waiting processes in a FIFO (first in—first out) way.

A resource needs a reference to an `Environment` and a capacity when it is created:

```@meta
DocTestSetup = quote
  using ResumableFunctions
  using ConcurrentSim

  @resumable function car(env::Environment, name::Int, bcs::Resource, driving_time::Number, charge_duration::Number)
    @yield timeout(sim, driving_time)
    println(name, " arriving at ", now(env))
    @yield lock(bcs)
    println(name, " starting to charge at ", now(env))
    @yield timeout(sim, charge_duration)
    println(name, " leaving the bcs at ", now(env))
    @yield release(bcs)
  end
end
```

```jldoctest
julia> sim = Simulation()
ConcurrentSim.Simulation time: 0.0 active_process: nothing

julia> bcs = Resource(sim, 2)
ConcurrentSim.Resource
```

We can now create the car processes and pass a reference to our resource as well as some additional parameters to them

```@meta
DocTestSetup = quote
  using ResumableFunctions
  using ConcurrentSim

  @resumable function car(env::Environment, name::Int, bcs::Resource, driving_time::Number, charge_duration::Number)
    @yield timeout(sim, driving_time)
    println(name, " arriving at ", now(env))
    @yield lock(bcs)
    println(name, " starting to charge at ", now(env))
    @yield timeout(sim, charge_duration)
    println(name, " leaving the bcs at ", now(env))
    @yield release(bcs)
  end

  sim = Simulation()
  bcs = Resource(sim, 2)
end
```

```jldoctest
julia> for i in 1:4
         @process car(sim, i, bcs, 2i, 5)
       end

julia> run(sim)
1 arriving at 2.0
1 starting to charge at 2.0
2 arriving at 4.0
2 starting to charge at 4.0
3 arriving at 6.0
1 leaving the bcs at 7.0
3 starting to charge at 7.0
4 arriving at 8.0
2 leaving the bcs at 9.0
4 starting to charge at 9.0
3 leaving the bcs at 12.0
4 leaving the bcs at 14.0
```

Finally, we can start the simulation. Since the car processes all terminate on their own in this simulation, we don’t need to specify an until time — the simulation will automatically stop when there are no more events left:

```@meta
DocTestSetup = quote
  using ResumableFunctions
  using ConcurrentSim

  @resumable function car(env::Environment, name::Int, bcs::Resource, driving_time::Number, charge_duration::Number)
    @yield timeout(sim, driving_time)
    println(name, " arriving at ", now(env))
    @yield lock(bcs)
    println(name, " starting to charge at ", now(env))
    @yield timeout(sim, charge_duration)
    println(name, " leaving the bcs at ", now(env))
    @yield release(bcs)
  end

  sim = Simulation()
  bcs = Resource(sim, 2)
  for i in 1:4
    @process car(sim, i, bcs, 2i, 5)
  end
end
```

```jldoctest
julia> run(sim)
1 arriving at 2.0
1 starting to charge at 2.0
2 arriving at 4.0
2 starting to charge at 4.0
3 arriving at 6.0
1 leaving the bcs at 7.0
3 starting to charge at 7.0
4 arriving at 8.0
2 leaving the bcs at 9.0
4 starting to charge at 9.0
3 leaving the bcs at 12.0
4 leaving the bcs at 14.0
```

```@meta
DocTestSetup = nothing
```

Note that the first two cars can start charging immediately after they arrive at the BCS, while cars 3 and 4 have to wait.
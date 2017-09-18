var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#Overview-1",
    "page": "Home",
    "title": "Overview",
    "category": "section",
    "text": "SimJulia is a discrete-event process-oriented simulation framework written in Julia inspired by the Python library SimPy. Its process dispatcher is based on semi-coroutines scheduling as implemented in ResumableFunctions. A Process in SimJulia is defined by a @resumable function yielding Events. SimJulia provides three types of shared resources to model limited capacity congestion points: Resources, Containers and Stores. The API is modeled after the SimPy API but some specific Julia semantics are used.The documentation contains a tutorial, topical guides explaining key concepts, a number of examples and the API reference. The tutorial, the topical guides and some examples are borrowed from SimPy to allow a direct comparison and an easy migration path for users. The differences between SimJulia and SimPy are clearly documented."
},

{
    "location": "index.html#Example-1",
    "page": "Home",
    "title": "Example",
    "category": "section",
    "text": "A short example simulating two clocks ticking in different time intervals looks like this:julia> using ResumableFunctions\n\njulia> using SimJulia\n\njulia> @resumable function clock(sim::Simulation, name::String, tick::Float64)\n         while true\n           println(name, \" \", now(sim))\n           @yield timeout(sim, tick)\n         end\n       end\nclock (generic function with 1 method)\n\njulia> sim = Simulation()\nSimJulia.Simulation time: 0.0 active_process: nothing\n\njulia> @process clock(sim, \"fast\", 0.5)\nSimJulia.Process 1\n\njulia> @process clock(sim, \"slow\", 1.0)\nSimJulia.Process 3\n\njulia> run(sim, 2)\nfast 0.0\nslow 0.0\nfast 0.5\nslow 1.0\nfast 1.0\nfast 1.5"
},

{
    "location": "index.html#Installation-1",
    "page": "Home",
    "title": "Installation",
    "category": "section",
    "text": "SimJulia is a registered package and can be installed by running:Pkg.add(\"SimJulia\")"
},

{
    "location": "index.html#Authors-1",
    "page": "Home",
    "title": "Authors",
    "category": "section",
    "text": "Ben Lauwens, Royal Military Academy, Brussels, Belgium."
},

{
    "location": "index.html#License-1",
    "page": "Home",
    "title": "License",
    "category": "section",
    "text": "SimJulia is licensed under the MIT \"Expat\" License."
},

{
    "location": "tutorial.html#",
    "page": "Tutorial",
    "title": "Tutorial",
    "category": "page",
    "text": ""
},

{
    "location": "tutorial.html#Tutorial-1",
    "page": "Tutorial",
    "title": "Tutorial",
    "category": "section",
    "text": ""
},

{
    "location": "tutorial.html#Basic-Concepts-1",
    "page": "Tutorial",
    "title": "Basic Concepts",
    "category": "section",
    "text": "Simjulia is a discrete-event simulation library. The behavior of active components (like vehicles, customers or messages) is modeled with processes. All processes live in an environment. They interact with the environment and with each other via events.Processes are described by @resumable functions. You can call them process function. During their lifetime, they create events and @yield them in order to wait for them to be triggered.note: Note\nDetailed information about the @resumable and the @yield macros can be found in the documentation of ResumableFunctions.When a process yields an event, the process gets suspended. SimJulia resumes the process, when the event occurs (we say that the event is triggered). Multiple processes can wait for the same event. SimJulia resumes them in the same order in which they yielded that event.An important event type is the timeout. Events of this type are scheduled after a certain amount of (simulated) time has passed. They allow a process to sleep (or hold its state) for the given time. A timeout and all other events can be created by calling a constructor having the environment as first argument."
},

{
    "location": "tutorial.html#Our-First-Process-1",
    "page": "Tutorial",
    "title": "Our First Process",
    "category": "section",
    "text": "Our first example will be a car process. The car will alternately drive and park for a while. When it starts driving (or parking), it will print the current simulation time.So let’s start:julia> using ResumableFunctions\n\njulia> using SimJulia\n\njulia> @resumable function car(env::Environment)\n           while true\n             println(\"Start parking at \", now(env))\n             parking_duration = 5\n             @yield timeout(env, parking_duration)\n             println(\"Start driving at \", now(env))\n             trip_duration = 2\n             @yield timeout(env, trip_duration)\n           end\n         end\ncar (generic function with 1 method)Our car process requires a reference to an Environment in order to create new events. The car‘s behavior is described in an infinite loop. Remember, the car function is a @resumable function. Though it will never terminate, it will pass the control flow back to the simulation once a @yield statement is reached. Once the yielded event is triggered (“it occurs”), the simulation will resume the function at this statement.As said before, our car switches between the states parking and driving. It announces its new state by printing a message and the current simulation time (as returned by the function call now). It then calls the constructor timeout to create a timeout event. This event describes the point in time the car is done parking (or driving, respectively). By yielding the event, it signals the simulation that it wants to wait for the event to occur.Now that the behavior of our car has been modeled, lets create an instance of it and see how it behaves:DocTestSetup = quote\n  using ResumableFunctions\n  using SimJulia\n\n  @resumable function car(env::Environment)\n    while true\n      println(\"Start parking at \", now(env))\n      parking_duration = 5\n      @yield timeout(env, parking_duration)\n      println(\"Start driving at \", now(env))\n      trip_duration = 2\n      @yield timeout(env, trip_duration)\n    end\n  end\nendjulia> sim = Simulation()\nSimJulia.Simulation time: 0.0 active_process: nothing\n\njulia> @process car(sim)\nSimJulia.Process 1\n\njulia> run(sim, 15)\nStart parking at 0.0\nStart driving at 5.0\nStart parking at 7.0\nStart driving at 12.0\nStart parking at 14.0DocTestSetup = nothingThe first thing we need to do is to create an environment, e.g. an instance of Simulation. The macro @process having as argument a car process function call creates a process that is initialised and added to the environment automatically.Note, that at this time, none of the code of our process function is being executed. Its execution is merely scheduled at the current simulation time.The Process returned by the @process macro can be used for process interactions.Finally, we start the simulation by calling run and passing an end time to it."
},

{
    "location": "tutorial.html#Process-Interaction-1",
    "page": "Tutorial",
    "title": "Process Interaction",
    "category": "section",
    "text": "The Process instance that is returned by @process macro can be utilized for process interactions. The two most common examples for this are to wait for another process to finish and to interrupt another process while it is waiting for an event."
},

{
    "location": "tutorial.html#Waiting-for-a-Process-1",
    "page": "Tutorial",
    "title": "Waiting for a Process",
    "category": "section",
    "text": "As it happens, a SimJulia Process can be used like an event. If you yield it, you are resumed once the process has finished. Imagine a car-wash simulation where cars enter the car-wash and wait for the washing process to finish, or an airport simulation where passengers have to wait until a security check finishes.Lets assume that the car from our last example is an electric vehicle. Electric vehicles usually take a lot of time charging their batteries after a trip. They have to wait until their battery is charged before they can start driving again.We can model this with an additional charge process for our car. Therefore, we redefine our car process function and add a charge process function.A new charge process is started every time the vehicle starts parking. By yielding the Process instance that the @process macro returns, the run process starts waiting for it to finish:julia> using ResumableFunctions\n\njulia> using SimJulia\n\njulia> @resumable function charge(env::Environment, duration::Number)\n         @yield timeout(env, duration)\n       end\ncharge (generic function with 1 method)\n\njulia> @resumable function car(env::Environment)\n         while true\n           println(\"Start parking and charging at \", now(env))\n           charge_duration = 5\n           charge_process = @process charge(sim, charge_duration)\n           @yield charge_process\n           println(\"Start driving at \", now(env))\n           trip_duration = 2\n           @yield timeout(sim, trip_duration)\n         end\n       end\ncar (generic function with 1 method)DocTestSetup = quote\n  using ResumableFunctions\n\n  using SimJulia\n\n  @resumable function charge(env::Environment, duration::Number)\n    @yield timeout(env, duration)\n  end\n\n  @resumable function car(env::Environment)\n    while true\n      println(\"Start parking and charging at \", now(env))\n      charge_duration = 5\n      charge_process = @process charge(sim, charge_duration)\n      @yield charge_process\n      println(\"Start driving at \", now(env))\n      trip_duration = 2\n      @yield timeout(sim, trip_duration)\n    end\n  end\nendStarting the simulation is straightforward again: We create a Simulation, one (or more) cars and finally call run.julia> sim = Simulation()\nSimJulia.Simulation time: 0.0 active_process: nothing\n\njulia> @process car(sim)\nSimJulia.Process 1\n\njulia> run(sim, 15)\nStart parking and charging at 0.0\nStart driving at 5.0\nStart parking and charging at 7.0\nStart driving at 12.0\nStart parking and charging at 14.0DocTestSetup = nothing"
},

{
    "location": "tutorial.html#Interrupting-Another-Process-1",
    "page": "Tutorial",
    "title": "Interrupting Another Process",
    "category": "section",
    "text": "Imagine, you don’t want to wait until your electric vehicle is fully charged but want to interrupt the charging process and just start driving instead.SimJulia allows you to interrupt a running process by calling the interrupt function:julia> using ResumableFunctions\n\njulia> using SimJulia\n\njulia> @resumable function driver(env::Environment, car_process::Process)\n         @yield timeout(env, 3)\n         @yield interrupt(car_process)\n       end\ndriver (generic function with 1 method)The driver process has a reference to the car process. After waiting for 3 time steps, it interrupts that process.Interrupts are thrown into process functions as Interrupt exceptions that can (should) be handled by the interrupted process. The process can then decide what to do next (e.g., continuing to wait for the original event or yielding a new event):DocTestSetup = quote\n  using ResumableFunctions\n  using SimJulia\nendjulia> @resumable function charge(env::Environment, duration::Number)\n         @yield timeout(env, duration)\n       end\ncharge (generic function with 1 method)\n\njulia> @resumable function car(env::Environment)\n         while true\n           println(\"Start parking and charging at \", now(env))\n           charge_duration = 5\n           charge_process = @process charge(sim, charge_duration)\n           try\n             @yield charge_process\n           catch\n             println(\"Was interrupted. Hopefully, the battery is full enough ...\")\n           end\n           println(\"Start driving at \", now(env))\n           trip_duration = 2\n           @yield timeout(sim, trip_duration)\n         end\n       end\ncar (generic function with 1 method)When you compare the output of this simulation with the previous example, you’ll notice that the car now starts driving at time 3 instead of 5:DocTestSetup = quote\n  using ResumableFunctions\n  using SimJulia\n\n  @resumable function driver(env::Environment, car_process::Process)\n    @yield timeout(env, 3)\n    @yield interrupt(car_process)\n  end\n\n  @resumable function charge(env::Environment, duration::Number)\n    @yield timeout(env, duration)\n  end\n\n  @resumable function car(env::Environment)\n    while true\n      println(\"Start parking and charging at \", now(env))\n      charge_duration = 5\n      charge_process = @process charge(sim, charge_duration)\n      try\n        @yield charge_process\n      catch\n        println(\"Was interrupted. Hopefully, the battery is full enough ...\")\n      end\n      println(\"Start driving at \", now(env))\n      trip_duration = 2\n      @yield timeout(sim, trip_duration)\n    end\n  end\nendjulia> sim = Simulation()\nSimJulia.Simulation time: 0.0 active_process: nothing\n\njulia> car_process = @process car(sim)\nSimJulia.Process 1\n\njulia> @process driver(sim, car_process)\nSimJulia.Process 3\n\njulia> run(sim, 15)\nStart parking and charging at 0.0\nWas interrupted. Hopefully, the battery is full enough ...\nStart driving at 3.0\nStart parking and charging at 5.0\nStart driving at 10.0\nStart parking and charging at 12.0DocTestSetup = nothing"
},

{
    "location": "tutorial.html#Shared-Resources-1",
    "page": "Tutorial",
    "title": "Shared Resources",
    "category": "section",
    "text": "SimJulia offers three types of resources that help you modeling problems, where multiple processes want to use a resource of limited capacity (e.g., cars at a fuel station with a limited number of fuel pumps) or classical producer-consumer problems.In this section, we’ll briefly introduce SimJulia’s Resource class."
},

{
    "location": "tutorial.html#Basic-Resource-Usage-1",
    "page": "Tutorial",
    "title": "Basic Resource Usage",
    "category": "section",
    "text": "We’ll slightly modify our electric vehicle process car that we introduced in the last sections.The car will now drive to a battery charging station (BCS) and request one of its two charging spots. If both of these spots are currently in use, it waits until one of them becomes available again. It then starts charging its battery and leaves the station afterwards:julia> using ResumableFunctions\n\njulia> using SimJulia\n\njulia> @resumable function car(env::Environment, name::Int, bcs::Resource, driving_time::Number, charge_duration::Number)\n         @yield timeout(sim, driving_time)\n         println(name, \" arriving at \", now(env))\n         @yield request(bcs)\n         println(name, \" starting to charge at \", now(env))\n         @yield timeout(sim, charge_duration)\n         println(name, \" leaving the bcs at \", now(env))\n         @yield release(bcs)\n       end\ncar (generic function with 1 method)The resource’s request function generates an event that lets you wait until the resource becomes available again. If you are resumed, you “own” the resource until you release it.You are responsible to call release once you are done using the resource. When you release a resource, the next waiting process is resumed and now “owns” one of the resource’s slots. The basic Resource sorts waiting processes in a FIFO (first in—first out) way.A resource needs a reference to an Environment and a capacity when it is created:DocTestSetup = quote\n  using ResumableFunctions\n  using SimJulia\n\n  @resumable function car(env::Environment, name::Int, bcs::Resource, driving_time::Number, charge_duration::Number)\n    @yield timeout(sim, driving_time)\n    println(name, \" arriving at \", now(env))\n    @yield request(bcs)\n    println(name, \" starting to charge at \", now(env))\n    @yield timeout(sim, charge_duration)\n    println(name, \" leaving the bcs at \", now(env))\n    @yield release(bcs)\n  end\nendjulia> sim = Simulation()\nSimJulia.Simulation time: 0.0 active_process: nothing\n\njulia> bcs = Resource(sim, 2)\nSimJulia.Container{Int64}We can now create the car processes and pass a reference to our resource as well as some additional parameters to themDocTestSetup = quote\n  using ResumableFunctions\n  using SimJulia\n\n  @resumable function car(env::Environment, name::Int, bcs::Resource, driving_time::Number, charge_duration::Number)\n    @yield timeout(sim, driving_time)\n    println(name, \" arriving at \", now(env))\n    @yield request(bcs)\n    println(name, \" starting to charge at \", now(env))\n    @yield timeout(sim, charge_duration)\n    println(name, \" leaving the bcs at \", now(env))\n    @yield release(bcs)\n  end\n\n  sim = Simulation()\n  bcs = Resource(sim, 2)\nendjulia> for i in 1:4\n         @process car(sim, i, bcs, 2i, 5)\n       end\n\njulia> run(sim)\n1 arriving at 2.0\n1 starting to charge at 2.0\n2 arriving at 4.0\n2 starting to charge at 4.0\n3 arriving at 6.0\n1 leaving the bcs at 7.0\n3 starting to charge at 7.0\n4 arriving at 8.0\n2 leaving the bcs at 9.0\n4 starting to charge at 9.0\n3 leaving the bcs at 12.0\n4 leaving the bcs at 14.0Finally, we can start the simulation. Since the car processes all terminate on their own in this simulation, we don’t need to specify an until time — the simulation will automatically stop when there are no more events left:DocTestSetup = quote\n  using ResumableFunctions\n  using SimJulia\n\n  @resumable function car(env::Environment, name::Int, bcs::Resource, driving_time::Number, charge_duration::Number)\n    @yield timeout(sim, driving_time)\n    println(name, \" arriving at \", now(env))\n    @yield request(bcs)\n    println(name, \" starting to charge at \", now(env))\n    @yield timeout(sim, charge_duration)\n    println(name, \" leaving the bcs at \", now(env))\n    @yield release(bcs)\n  end\n\n  sim = Simulation()\n  bcs = Resource(sim, 2)\n  for i in 1:4\n    @process car(sim, i, bcs, 2i, 5)\n  end\nendjulia> run(sim)\n1 arriving at 2.0\n1 starting to charge at 2.0\n2 arriving at 4.0\n2 starting to charge at 4.0\n3 arriving at 6.0\n1 leaving the bcs at 7.0\n3 starting to charge at 7.0\n4 arriving at 8.0\n2 leaving the bcs at 9.0\n4 starting to charge at 9.0\n3 leaving the bcs at 12.0\n4 leaving the bcs at 14.0DocTestSetup = nothingNote that the first two cars can start charging immediately after they arrive at the BCS, while cars 3 and 4 have to wait."
},

{
    "location": "guides/basics.html#",
    "page": "Basics",
    "title": "Basics",
    "category": "page",
    "text": ""
},

{
    "location": "guides/basics.html#SimJulia-basics-1",
    "page": "Basics",
    "title": "SimJulia basics",
    "category": "section",
    "text": "This guide describes the basic concepts of SimJulia: How does it work? What are processes, events and the environment? What can I do with them?"
},

{
    "location": "guides/basics.html#How-SimJulia-works-1",
    "page": "Basics",
    "title": "How SimJulia works",
    "category": "section",
    "text": "If you break SimJulia down, it is just an asynchronous event dispatcher. You generate events and schedule them at a given simulation time. Events are sorted by priority, simulation time, and an increasing event id. An event also has a list of callbacks, which are executed when the event is triggered and processed by the event loop. Events may also have a return value.The components involved in this are the Environment, events and the process functions that you write.Process functions implement your simulation model, that is, they define the behavior of your simulation. They are @resumable functions that @yield instances of AbstractEvent.The environment stores these events in its event list and keeps track of the current simulation time.If a process function yields an event, SimJulia adds the process to the event’s callbacks and suspends the process until the event is triggered and processed. When a process waiting for an event is resumed, it will also receive the event’s value.Here is a very simple example that illustrates all this:using ResumableFunctions\nusing SimJulia\n\n@resumable function example(env::Environment)\n  event = timeout(env, 1, value=42)\n  value = @yield event\n  println(\"now=\", now(env), \", value=\", value)\nend\n\nsim = Simulation()\n@process example(sim)\nrun(sim)\n\n# output\n\nnow=1.0, value=42The example process function above first creates a timeout event. It passes the environment, a delay, and a value to it. The timeout schedules itself at now + delay (that’s why the environment is required); other event types usually schedule themselves at the current simulation time.The process function then yields the event and thus gets suspended. It is resumed, when SimJulia processes the timeout event. The process function also receives the event’s value (42) – this is, however, optional, so @yield event would have been okay if the you were not interested in the value or if the event had no value at all.Finally, the process function prints the current simulation time (that is accessible via the now function) and the timeout’s value.If all required process functions are defined, you can instantiate all objects for your simulation. In most cases, you start by creating an instance of Environment, e.g. a Simulation, because you’ll need to pass it around a lot when creating everything else.Starting a process function involves two things:You have to call the macro @process with as argument a call to the process function. (This will not execute any code of that function yet.) This will schedule an initialisation event at the current simulation time which starts the execution of the process function. The process instance is also an event that is triggered when the process function returns.\nFinally, you can start SimJulia’s event loop. By default, it will run as long as there are events in the event list, but you can also let it stop earlier by providing an until argument."
},

{
    "location": "guides/environments.html#",
    "page": "Environments",
    "title": "Environments",
    "category": "page",
    "text": ""
},

{
    "location": "guides/environments.html#Environments-1",
    "page": "Environments",
    "title": "Environments",
    "category": "section",
    "text": "A simulation environment manages the simulation time as well as the scheduling and processing of events. It also provides means to step through or execute the simulation.The base type for all environments is Environment. “Normal” simulations use its subtype Simulation."
},

{
    "location": "guides/environments.html#Simulation-control-1",
    "page": "Environments",
    "title": "Simulation control",
    "category": "section",
    "text": "SimJulia is very flexible in terms of simulation execution. You can run your simulation until there are no more events, until a certain simulation time is reached, or until a certain event is triggered. You can also step through the simulation event by event. Furthermore, you can mix these things as you like.For example, you could run your simulation until an interesting event occurs. You could then step through the simulation event by event for a while; and finally run the simulation until there are no more events left and your processes have all terminated.The most important function here is run:If you call it with an instance of the environment as the only argument  (run(env)), it steps through the simulation until there are no more events left. If your processes run forever, this function will never terminate (unless you kill your script by e.g., pressing Ctrl-C).\nIn most cases it is advisable to stop your simulation when it reaches a certain simulation time. Therefore, you can pass the desired time via a second argument, e.g.: run(env, 10).\nThe simulation will then stop when the internal clock reaches 10 but will not process any events scheduled for time 10. This is similar to a new environment where the clock is 0 but (obviously) no events have yet been processed.\nIf you want to integrate your simulation in a GUI and want to draw a process bar, you can repeatedly call this function with increasing until values and update your progress bar after each call:sim = Simulation()\nfor t in 1:100\n  run(sim, t)\n  update(progressbar, t)\nendInstead of passing a number as second argument to run, you can also pass any event to it. run will then return when the event has been processed.\nAssuming that the current time is 0, run(env, timeout(env, 5)) is equivalent to run(env, 5).\nYou can also pass other types of events (remember, that a Process is an event, too):using ResumableFunctions\nusing SimJulia\n\n@resumable function my_process(env::Environment)\n  @yield timeout(env, 1)\n  \"Monty Python's Flying Circus\"\nend\n\nsim = Simulation()\nproc = @process my_process(sim)\nrun(sim, proc)\n\n# output\n\n\"Monty Python's Flying Circus\"To step through the simulation event by event, the environment offers step. This function processes the next scheduled event. It raises an EmptySchedule exception if no event is available.In a typical use case, you use this function in a loop like:while now(sim) < 10\n  step(sim)\nend"
},

{
    "location": "guides/environments.html#State-access-1",
    "page": "Environments",
    "title": "State access",
    "category": "section",
    "text": "The environment allows you to get the current simulation time via the function now. The simulation time is a number without unit and is increased via timeout events.By default, the simulation starts at time 0, but you can pass an initial_time to the Simulation constructor to use something else.Notenote: Note\nAlthough the simulation time is technically unitless, you can pretend that it is, for example, in milliseconds and use it like a timestamp returned by Base.Dates.datetime2epochm to calculate a date or the day of the week. The Simulation constructor and the run function accept as argument a Base.Dates.DateTime and the timeout constructor a Base.Dates.Delay. Together with the convenience function nowDateTime a simulation can transparantly schedule its events in seconds, minutes, hours, days, ...The function active_process is comparable to Base.Libc.getpid and returns the current active Process. If no process is active, a NullException is thrown. A process is active when its process function is being executed. It becomes inactive (or suspended) when it yields an event.Thus, it only makes sense to call this function from within a process function or a function that is called by your process function:julia> using ResumableFunctions\n\njulia> using SimJulia\n\njulia> function subfunc(env::Environment)\n         println(active_process(env))\n       end\nsubfunc (generic function with 1 method)\n\njulia> @resumable function my_proc(env::Environment)\n         while true\n           println(active_process(env))\n           subfunc(env)\n           @yield timeout(env, 1)\n         end\n       end\nmy_proc (generic function with 1 method)\n\njulia> sim = Simulation()\nSimJulia.Simulation time: 0.0 active_process: nothing\n\njulia> @process my_proc(sim)\nSimJulia.Process 1\n\njulia> active_process(sim)\nERROR: NullException()\n[...]\n\njulia> SimJulia.step(sim)\nSimJulia.Process 1\nSimJulia.Process 1\n\njulia> active_process(sim)\nERROR: NullException()\n[...]An exemplary use case for this is the resource system: If a process function calls request to request a Resource, the resource determines the requesting process via active_process."
},

{
    "location": "guides/environments.html#Miscellaneous-1",
    "page": "Environments",
    "title": "Miscellaneous",
    "category": "section",
    "text": "A generator function can have a return value:@resumable function my_proc(env::Environment)\n  @yield timeout(sim, 1)\n  150\nendIn SimJulia, this can be used to provide return values for processes that can be used by other processes:@resumable function other_proc(env::Environment)\n  ret_val = @yield @process my_proc(env)\n  @assert ret_val == 150\nend"
},

{
    "location": "guides/events.html#",
    "page": "Events",
    "title": "Events",
    "category": "page",
    "text": ""
},

{
    "location": "guides/events.html#Events-1",
    "page": "Events",
    "title": "Events",
    "category": "section",
    "text": "SimJulia includes an extensive set of event types for various purposes. All of them are descendants of AbstractEvent. Here the following events are discussed:Event\ntimeout\nOperatorThe guide to resources describes the various resource events."
},

{
    "location": "guides/events.html#Event-basics-1",
    "page": "Events",
    "title": "Event basics",
    "category": "section",
    "text": "SimJulia events are very similar – if not identical — to deferreds, futures or promises. Instances of the type AbstractEvent are used to describe any kind of events. Events can be in one of the following states. An event:might happen (idle),\nis going to happen (scheduled) or\nhas happened (processed).They traverse these states exactly once in that order. Events are also tightly bound to time and time causes events to advance their state.Initially, events are idle and the function state returns SimJulia.idle.If an event gets scheduled at a given time, it is inserted into SimJulia’s event queue. The function state returns SimJulia.scheduled.As long as the event is not processed, you can add callbacks to an event. Callbacks are function having an AbstractEvent as first parameter.An event becomes processed when SimJulia pops it from the event queue and calls all of its callbacks. It is now no longer possible to add callbacks. The function state returns SimJulia.processed.Events also have a value. The value can be set before or when the event is scheduled and can be retrieved via the function value or, within a process, by yielding the event (value = @yield event)."
},

{
    "location": "guides/events.html#Adding-callbacks-to-an-event-1",
    "page": "Events",
    "title": "Adding callbacks to an event",
    "category": "section",
    "text": "“What? Callbacks? I’ve never seen no callbacks!”, you might think if you have worked your way through the tutorial.That’s on purpose. The most common way to add a callback to an event is yielding it from your process function (@yield event). This will add the process’ resume function as a callback. That’s how your process gets resumed when it yielded an event.However, you can add any function to the list of callbacks as long as it accepts AbstractEvent or a descendant as first parameter:julia> using SimJulia\n\njulia> function my_callback(ev::AbstractEvent)\n         println(\"Called back from \", ev)\n       end\nmy_callback (generic function with 1 method)\n\njulia> sim = Simulation()\nSimJulia.Simulation time: 0.0 active_process: nothing\n\njulia> ev = Event(sim)\nSimJulia.Event 1\n\njulia> @callback my_callback(ev)\n(::#3) (generic function with 1 method)\n\njulia> succeed(ev)\nSimJulia.Event 1\n\njulia> run(sim)\nCalled back from SimJulia.Event 1"
},

{
    "location": "examples/ross.html#",
    "page": "Ross",
    "title": "Ross",
    "category": "page",
    "text": ""
},

{
    "location": "examples/ross.html#Ross,-Simulation-5th-edition:-1",
    "page": "Ross",
    "title": "Ross, Simulation 5th edition:",
    "category": "section",
    "text": ""
},

{
    "location": "examples/ross.html#A-repair-problem-1",
    "page": "Ross",
    "title": "A repair problem",
    "category": "section",
    "text": ""
},

{
    "location": "examples/ross.html#Source-1",
    "page": "Ross",
    "title": "Source",
    "category": "section",
    "text": "Ross, Simulation 5th edition, Section 7.7, p. 124-126"
},

{
    "location": "examples/ross.html#Description-1",
    "page": "Ross",
    "title": "Description",
    "category": "section",
    "text": "A system needs n working machines to be operational. To guard against machine breakdown, additional machines are kept available as spares. Whenever a machine breaks down it is immediately replaced by a spare and is itself sent to the repair facility, which consists of a single repairperson who repairs failed machines one at a time. Once a failed machine has been repaired it becomes available as a spare to be used when the need arises. All repair times are independent random variables having the common distribution function G. Each time a machine is put into use the amount of time it functions before breaking down is a random variable, independent of the past, having distribution function F.The system is said to “crash” when a machine fails and no spares are available. Assuming that there are initially n + s functional machines of which n are put in use and s are kept as spares, we are interested in simulating this system so as to approximate ET, where T is the time at which the system crashes."
},

{
    "location": "examples/ross.html#Code-1",
    "page": "Ross",
    "title": "Code",
    "category": "section",
    "text": "using Distributions\nusing ResumableFunctions\nusing SimJulia\n\nconst RUNS = 5\nconst N = 10\nconst S = 3\nconst SEED = 150\nconst LAMBDA = 100\nconst MU = 1\n\nsrand(SEED)\nconst F = Exponential(LAMBDA)\nconst G = Exponential(MU)\n\n@resumable function machine(env::Environment, repair_facility::Resource, spares::Store{Process})\n    while true\n        try @yield timeout(env, Inf) end\n        @yield timeout(env, rand(F))\n        get_spare = get(spares)\n        @yield get_spare | timeout(env)\n        if state(get_spare) != SimJulia.idle \n            @yield interrupt(value(get_spare))\n        else\n            throw(SimJulia.StopSimulation(\"No more spares!\"))\n        end\n        @yield request(repair_facility)\n        @yield timeout(env, rand(G))\n        @yield release(repair_facility)\n        @yield put(spares, active_process(env))\n    end\nend\n\n@resumable function start_sim(env::Environment, repair_facility::Resource, spares::Store{Process})\n    for i in 1:N\n        proc = @process machine(env, repair_facility, spares)\n        @yield interrupt(proc)\n    end\n    for i in 1:S\n        proc =  @process machine(env, repair_facility, spares)\n        @yield put(spares, proc) \n    end\nend\n\nfunction sim_repair()\n    sim = Simulation()\n    repair_facility = Resource(sim)\n    spares = Store{Process}(sim)\n    @process start_sim(sim, repair_facility, spares)\n    msg = run(sim)\n    stop_time = now(sim)\n    println(\"At time $stop_time: $msg\")\n    stop_time\nend\n\nresults = Float64[]\nfor i in 1:RUNS push!(results, sim_repair()) end\nprintln(\"Average crash time: \", sum(results)/RUNS)\n\n# output\n\nAt time 5573.772841846017: No more spares!\nAt time 1438.0294516073466: No more spares!\nAt time 7077.413276961621: No more spares!\nAt time 7286.490682742159: No more spares!\nAt time 6820.788098062124: No more spares!\nAverage crash time: 5639.298870243853"
},

{
    "location": "api.html#",
    "page": "API",
    "title": "API",
    "category": "page",
    "text": ""
},

{
    "location": "api.html#API-1",
    "page": "API",
    "title": "API",
    "category": "section",
    "text": ""
},

]}

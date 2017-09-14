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
    "text": "SimJulia is a discrete-event process-oriented simulation framework written in Julia inspired by the Python library SimPy. Its process dispatcher is based on semi-coroutines scheduling as implemented in ResumableFunctions. A Process in SimJulia is defined by a @resumable function yielding Events. SimJulia provides three types of shared resources to model limited capacity congestion points: Resources, Containers and Stores. The API is modeled after the SimPy API but some specific Julia semantics are used.The documentation contains a tutorial, topical guides explaining key concepts, a number of examples and the API reference. The tutorial, the topical guides and some examples are borrowed from the SimPy to allow a direct comparison and an easy migration path for users. The differences between SimJulia and SimPy are clearly documented."
},

{
    "location": "index.html#Example-1",
    "page": "Home",
    "title": "Example",
    "category": "section",
    "text": "A short example simulating two clocks ticking in different time intervals looks like this:julia> using ResumableFunctions\n\njulia> using SimJulia\n\njulia> @resumable function clock(sim::Simulation, name::String, tick::Float64)\n         while true\n           println(name, \" \", now(sim))\n           @yield Timeout(sim, tick)\n         end\n       end\nclock (generic function with 1 method)\n\njulia> sim = Simulation()\nSimJulia.Simulation(0.0, DataStructures.PriorityQueue{SimJulia.BaseEvent,SimJulia.EventKey,Base.Order.ForwardOrdering}(), 0x0000000000000000, 0x0000000000000000, Nullable{SimJulia.AbstractProcess}())\n\njulia> @process clock(sim, \"fast\", 0.5)\nSimJulia.Process 1\n\njulia> @process clock(sim, \"slow\", 1.0)\nSimJulia.Process 3\n\njulia> run(sim, 2)\nfast 0.0\nslow 0.0\nfast 0.5\nslow 1.0\nfast 1.0\nfast 1.5"
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
    "text": "Simjulia is a discrete-event simulation library. The behavior of active components (like vehicles, customers or messages) is modeled with processes. All processes live in an environment, e.g. a Simulation. They interact with the environment and with each other via Events.Processes are described by @resumable functions. You can call them process function. During their lifetime, they create events and @yield them in order to wait for them to be triggered.When a process yields an event, the process gets suspended. SimJulia resumes the process, when the event occurs (we say that the event is triggered). Multiple processes can wait for the same event. SimJulia resumes them in the same order in which they yielded that event.An important event type is the Timeout. Events of this type are triggered after a certain amount of (simulated) time has passed. They allow a process to sleep (or hold its state) for the given time. A Timeout and all other events can be created by calling a constructor having the environment as first argument."
},

{
    "location": "tutorial.html#Our-First-Process-1",
    "page": "Tutorial",
    "title": "Our First Process",
    "category": "section",
    "text": "Our first example will be a car process. The car will alternately drive and park for a while. When it starts driving (or parking), it will print the current simulation time.So let’s start:julia> using ResumableFunctions\n\njulia> using SimJulia\n\njulia> @resumable function car(env::Environment)\n           while true\n             println(\"Start parking at \", now(env))\n             parking_duration = 5\n             @yield Timeout(env, parking_duration)\n             println(\"Start driving at \", now(env))\n             trip_duration = 2\n             @yield Timeout(env, trip_duration)\n           end\n         end\ncar (generic function with 1 method)Our car process requires a reference to an Environment (env) in order to create new events. The car‘s behavior is described in an infinite loop. Remember, the car function is a @resumable function. Though it will never terminate, it will pass the control flow back to the simulation once a @yield statement is reached. Once the yielded event is triggered (“it occurs”), the simulation will resume the function at this statement.As said before, our car switches between the states parking and driving. It announces its new state by printing a message and the current simulation time (as returned by the function call now(env)). It then calls the constructor Timeout(env) to create a timeout event. This event describes the point in time the car is done parking (or driving, respectively). By yielding the event, it signals the simulation that it wants to wait for the event to occur.Now that the behavior of our car has been modeled, lets create an instance of it and see how it behaves:DocTestSetup = quote\n  using ResumableFunctions\n  using SimJulia\n\n  @resumable function car(env::Environment)\n    while true\n      println(\"Start parking at \", now(env))\n      parking_duration = 5\n      @yield Timeout(env, parking_duration)\n      println(\"Start driving at \", now(env))\n      trip_duration = 2\n      @yield Timeout(env, trip_duration)\n    end\n  end\nendjulia> sim = Simulation()\nSimJulia.Simulation(0.0, DataStructures.PriorityQueue{SimJulia.BaseEvent,SimJulia.EventKey,Base.Order.ForwardOrdering}(), 0x0000000000000000, 0x0000000000000000, Nullable{SimJulia.AbstractProcess}())\n\njulia> @process car(sim)\nSimJulia.Process 1\n\njulia> run(sim, 15)\nStart parking at 0.0\nStart driving at 5.0\nStart parking at 7.0\nStart driving at 12.0\nStart parking at 14.0DocTestSetup = nothingThe first thing we need to do is to create an Environment, i.e. an instance of Simulation. The macro @process with as argument a call to the car process function creates a process generator that is started and added to the environment automatically.Note, that at this time, none of the code of our process function is being executed. Its execution is merely scheduled at the current simulation time.The Process returned by the @process macro can be used for process interactions (we will cover that in the next section, so we will ignore it for now).Finally, we start the simulation by calling run and passing an end time to it."
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
    "text": "As it happens, a SimJulia Process can be used like an event. If you yield it, you are resumed once the process has finished. Imagine a car-wash simulation where cars enter the car-wash and wait for the washing process to finish. Or an airport simulation where passengers have to wait until a security check finishes.Lets assume that the car from our last example magically became an electric vehicle. Electric vehicles usually take a lot of time charging their batteries after a trip. They have to wait until their battery is charged before they can start driving again.We can model this with an additional charge process for our car. Therefore, we redefine our car process function and add a charge process function.A new charge process is started every time the vehicle starts parking. By yielding the Process instance that the @process macro returns, the run process starts waiting for it to finish:julia> using ResumableFunctions\n\njulia> using SimJulia\n\njulia> @resumable function charge(env::Environment, duration::Number)\n         @yield Timeout(env, duration)\n       end\ncharge (generic function with 1 method)\n\njulia> @resumable function car(env::Environment)\n         while true\n           println(\"Start parking and charging at \", now(env))\n           charge_duration = 5\n           charge_process = @process charge(sim, charge_duration)\n           @yield charge_process\n           println(\"Start driving at \", now(env))\n           trip_duration = 2\n           @yield Timeout(sim, trip_duration)\n         end\n       end\ncar (generic function with 1 method)DocTestSetup = quote\n  using ResumableFunctions\n\n  using SimJulia\n\n  @resumable function charge(env::Environment, duration::Number)\n    @yield Timeout(env, duration)\n  end\n\n  @resumable function car(env::Environment)\n    while true\n      println(\"Start parking and charging at \", now(env))\n      charge_duration = 5\n      charge_process = @process charge(sim, charge_duration)\n      @yield charge_process\n      println(\"Start driving at \", now(env))\n      trip_duration = 2\n      @yield Timeout(sim, trip_duration)\n    end\n  end\nendStarting the simulation is straightforward again: We create a Simulation, one (or more) cars and finally call run.julia> sim = Simulation()\nSimJulia.Simulation(0.0, DataStructures.PriorityQueue{SimJulia.BaseEvent,SimJulia.EventKey,Base.Order.ForwardOrdering}(), 0x0000000000000000, 0x0000000000000000, Nullable{SimJulia.AbstractProcess}())\n\njulia> @process car(sim)\nSimJulia.Process 1\n\njulia> run(sim, 15)\nStart parking and charging at 0.0\nStart driving at 5.0\nStart parking and charging at 7.0\nStart driving at 12.0\nStart parking and charging at 14.0DocTestSetup = nothing"
},

{
    "location": "tutorial.html#Interrupting-Another-Process-1",
    "page": "Tutorial",
    "title": "Interrupting Another Process",
    "category": "section",
    "text": "Imagine, you don’t want to wait until your electric vehicle is fully charged but want to interrupt the charging process and just start driving instead.SimJulia allows you to interrupt a running process by calling the interrupt function:julia> using ResumableFunctions\n\njulia> using SimJulia\n\njulia> @resumable function driver(env::Environment, car_process::Process)\n         @yield Timeout(env, 3)\n         interrupt(car_process)\n       end\ndriver (generic function with 1 method)The driver process has a reference to the car process. After waiting for 3 time steps, it interrupts that process.Interrupts are thrown into process functions as Interrupt exceptions that can (should) be handled by the interrupted process. The process can then decide what to do next (e.g., continuing to wait for the original event or yielding a new event):DocTestSetup = quote\n  using ResumableFunctions\n  using SimJulia\nendjulia> @resumable function charge(env::Environment, duration::Number)\n         @yield Timeout(env, duration)\n       end\ncharge (generic function with 1 method)\n\njulia> @resumable function car(env::Environment)\n         while true\n           println(\"Start parking and charging at \", now(env))\n           charge_duration = 5\n           charge_process = @process charge(sim, charge_duration)\n           try\n             @yield charge_process\n           catch\n             println(\"Was interrupted. Hopefully, the battery is full enough ...\")\n           end\n           println(\"Start driving at \", now(env))\n           trip_duration = 2\n           @yield Timeout(sim, trip_duration)\n         end\n       end\ncar (generic function with 1 method)When you compare the output of this simulation with the previous example, you’ll notice that the car now starts driving at time 3 instead of 5:DocTestSetup = quote\n  using ResumableFunctions\n  using SimJulia\n\n  @resumable function driver(env::Environment, car_process::Process)\n    @yield Timeout(env, 3)\n    interrupt(car_process)\n  end\n\n  @resumable function charge(env::Environment, duration::Number)\n    @yield Timeout(env, duration)\n  end\n\n  @resumable function car(env::Environment)\n    while true\n      println(\"Start parking and charging at \", now(env))\n      charge_duration = 5\n      charge_process = @process charge(sim, charge_duration)\n      try\n        @yield charge_process\n      catch\n        println(\"Was interrupted. Hopefully, the battery is full enough ...\")\n      end\n      println(\"Start driving at \", now(env))\n      trip_duration = 2\n      @yield Timeout(sim, trip_duration)\n    end\n  end\nendjulia> sim = Simulation()\nSimJulia.Simulation(0.0, DataStructures.PriorityQueue{SimJulia.BaseEvent,SimJulia.EventKey,Base.Order.ForwardOrdering}(), 0x0000000000000000, 0x0000000000000000, Nullable{SimJulia.AbstractProcess}())\n\njulia> car_process = @process car(sim)\nSimJulia.Process 1\n\njulia> @process driver(sim, car_process)\nSimJulia.Process 3\n\njulia> run(sim, 15)\nStart parking and charging at 0.0\nWas interrupted. Hopefully, the battery is full enough ...\nStart driving at 3.0\nStart parking and charging at 5.0\nStart driving at 10.0\nStart parking and charging at 12.0DocTestSetup = nothing"
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
    "text": "We’ll slightly modify our electric vehicle process car that we introduced in the last sections.The car will now drive to a battery charging station (BCS) and request one of its two charging spots. If both of these spots are currently in use, it waits until one of them becomes available again. It then starts charging its battery and leaves the station afterwards:julia> using ResumableFunctions\n\njulia> using SimJulia\n\njulia> @resumable function car(env::Environment, name::Int, bcs::Resource, driving_time::Number, charge_duration::Number)\n         @yield Timeout(sim, driving_time)\n         println(name, \" arriving at \", now(env))\n         @yield Request(bcs)\n         println(name, \" starting to charge at \", now(env))\n         @yield Timeout(sim, charge_duration)\n         println(name, \" leaving the bcs at \", now(env))\n         @yield Release(bcs)\n       end\ncar (generic function with 1 method)The resource’s request function generates an event that lets you wait until the resource becomes available again. If you are resumed, you “own” the resource until you release it.You are responsible to call release once you are done using the resource. When you release a resource, the next waiting process is resumed and now “owns” one of the resource’s slots. The basic Resource sorts waiting processes in a FIFO (first in—first out) way.A resource needs a reference to an Environment and a capacity when it is created:DocTestSetup = quote\n  using ResumableFunctions\n  using SimJulia\n\n  @resumable function car(env::Environment, name::Int, bcs::Resource, driving_time::Number, charge_duration::Number)\n    @yield Timeout(sim, driving_time)\n    println(name, \" arriving at \", now(env))\n    @yield Request(bcs)\n    println(name, \" starting to charge at \", now(env))\n    @yield Timeout(sim, charge_duration)\n    println(name, \" leaving the bcs at \", now(env))\n    @yield Release(bcs)\n  end\nendjulia> sim = Simulation()\nSimJulia.Simulation(0.0, DataStructures.PriorityQueue{SimJulia.BaseEvent,SimJulia.EventKey,Base.Order.ForwardOrdering}(), 0x0000000000000000, 0x0000000000000000, Nullable{SimJulia.AbstractProcess}())\n\njulia> bcs = Resource(sim, 2)\nSimJulia.Container{Int64}(SimJulia.Simulation(0.0, DataStructures.PriorityQueue{SimJulia.BaseEvent,SimJulia.EventKey,Base.Order.ForwardOrdering}(), 0x0000000000000000, 0x0000000000000000, Nullable{SimJulia.AbstractProcess}()), 2, 0, 0x0000000000000000, DataStructures.PriorityQueue{SimJulia.Put,SimJulia.ContainerKey{Int64},Base.Order.ForwardOrdering}(), DataStructures.PriorityQueue{SimJulia.Get,SimJulia.ContainerKey{Int64},Base.Order.ForwardOrdering}())We can now create the car processes and pass a reference to our resource as well as some additional parameters to themDocTestSetup = quote\n  using ResumableFunctions\n  using SimJulia\n\n  @resumable function car(env::Environment, name::Int, bcs::Resource, driving_time::Number, charge_duration::Number)\n    @yield Timeout(sim, driving_time)\n    println(name, \" arriving at \", now(env))\n    @yield Request(bcs)\n    println(name, \" starting to charge at \", now(env))\n    @yield Timeout(sim, charge_duration)\n    println(name, \" leaving the bcs at \", now(env))\n    @yield Release(bcs)\n  end\n\n  sim = Simulation()\n  bcs = Resource(sim, 2)\nendjulia> for i in 1:4\n         @process car(sim, i, bcs, 2i, 5)\n       end\n\njulia> run(sim)\n1 arriving at 2.0\n1 starting to charge at 2.0\n2 arriving at 4.0\n2 starting to charge at 4.0\n3 arriving at 6.0\n1 leaving the bcs at 7.0\n3 starting to charge at 7.0\n4 arriving at 8.0\n2 leaving the bcs at 9.0\n4 starting to charge at 9.0\n3 leaving the bcs at 12.0\n4 leaving the bcs at 14.0Finally, we can start the simulation. Since the car processes all terminate on their own in this simulation, we don’t need to specify an until time — the simulation will automatically stop when there are no more events left:DocTestSetup = quote\n  using ResumableFunctions\n  using SimJulia\n\n  @resumable function car(env::Environment, name::Int, bcs::Resource, driving_time::Number, charge_duration::Number)\n    @yield Timeout(sim, driving_time)\n    println(name, \" arriving at \", now(env))\n    @yield Request(bcs)\n    println(name, \" starting to charge at \", now(env))\n    @yield Timeout(sim, charge_duration)\n    println(name, \" leaving the bcs at \", now(env))\n    @yield Release(bcs)\n  end\n\n  sim = Simulation()\n  bcs = Resource(sim, 2)\n  for i in 1:4\n    @process car(sim, i, bcs, 2i, 5)\n  end\nendjulia> run(sim)\n1 arriving at 2.0\n1 starting to charge at 2.0\n2 arriving at 4.0\n2 starting to charge at 4.0\n3 arriving at 6.0\n1 leaving the bcs at 7.0\n3 starting to charge at 7.0\n4 arriving at 8.0\n2 leaving the bcs at 9.0\n4 starting to charge at 9.0\n3 leaving the bcs at 12.0\n4 leaving the bcs at 14.0DocTestSetup = nothingNote that the first two cars can start charging immediately after they arrive at the BCS, while cars 3 and 4 have to wait."
},

{
    "location": "guides/index.html#",
    "page": "Topical Guides",
    "title": "Topical Guides",
    "category": "page",
    "text": ""
},

{
    "location": "guides/index.html#Topical-Guides-1",
    "page": "Topical Guides",
    "title": "Topical Guides",
    "category": "section",
    "text": ""
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
    "text": "using Distributions\nusing ResumableFunctions\nusing SimJulia\n\nconst RUNS = 5\nconst N = 10\nconst S = 3\nconst SEED = 150\nconst LAMBDA = 100\nconst MU = 1\n\nsrand(SEED)\nconst F = Exponential(LAMBDA)\nconst G = Exponential(MU)\n\n@resumable function machine(sim::Simulation, repair_facility::Resource, spares::Store{Process})\n    while true\n        try\n            @yield Timeout(sim, Inf)\n        catch exc\n        end\n        @yield Timeout(sim, rand(F))\n        get_spare = Get(spares)\n        @yield get_spare | Timeout(sim, 0.0)\n        state(get_spare) != SimJulia.idle ? interrupt(value(get_spare)) : throw(SimJulia.StopSimulation(\"No more spares!\"))\n        @yield Request(repair_facility)\n        @yield Timeout(sim, rand(G))\n        @yield Release(repair_facility)\n        @yield Put(spares, active_process(sim))\n    end\nend\n\n@resumable function start_sim(sim::Simulation, repair_facility::Resource, spares::Store{Process})\n    procs = Process[]\n    for i=1:N\n        push!(procs, @process machine(sim, repair_facility, spares))\n    end\n    @yield Timeout(sim, 0.0)\n    for proc in procs\n        interrupt(proc)\n    end\n    for i=1:S\n        @yield Put(spares, @process machine(sim, repair_facility, spares))\n    end\nend\n\nfunction sim_repair()\n    sim = Simulation()\n    repair_facility = Resource(sim)\n    spares = Store{Process}(sim)\n    @process start_sim(sim, repair_facility, spares)\n    msg = run(sim)\n    stop_time = now(sim)\n    println(\"At time $stop_time: $msg\")\n    stop_time\nend\n\nresults = Float64[]\nfor i=1:RUNS\n    push!(results, sim_repair())\nend\nprintln(\"Average crash time: \", sum(results)/RUNS)\n\n# output\n\nAt time 5573.772841846017: No more spares!\nAt time 1438.0294516073466: No more spares!\nAt time 7077.413276961621: No more spares!\nAt time 7286.490682742159: No more spares!\nAt time 6820.788098062124: No more spares!\nAverage crash time: 5639.298870243853"
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

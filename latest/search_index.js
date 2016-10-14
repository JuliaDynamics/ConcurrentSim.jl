var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#SimJulia.jl-1",
    "page": "Home",
    "title": "SimJulia.jl",
    "category": "section",
    "text": "SimJulia is a combined continuous time / discrete event process oriented simulation framework written in Julia inspired by the Simula library DISCO and the Python library SimPy.Its event dispatcher is based on a Task. This is a control flow feature in Julia that allows computations to be suspended and resumed in a flexible manner. Processes in SimJulia are defined by functions yielding Events. SimJulia also provides three types of shared resources to model limited capacity congestion points: Resources, Containers and Stores. The API is modeled after the SimPy API but using some specific Julia semantics.A short example simulating two clocks ticking in different time intervals looks like this:using SimJulia\n\nfunction clock(sim::Simulation, name::String, tick::Float64)\n  while true\n    println(\"$name, $(now(sim))\")\n    yield(timeout(sim, tick))\n  end\nend\n\nsim = Simulation()\nProcess(clock, sim, \"fast\", 0.5)\nProcess(clock, sim, \"slow\", 1.0)\nrun(sim, 2.0)The continuous time simulation framework is still under development and is based on a quantized state system solver that naturally integrates in the discrete event framework. Events can be triggered on Zerocrossings of functions depending on the continuous Variables described by a system of differential equations.SimJulia contains tutorials, in-depth documentation, and a large number of examples. Most of the tutorials and the examples are borrowed from the SimPy distribution to allow a direct comparison and an easy migration path for users. The examples of continuous time simulation are heavily influenced by the examples in the DISCO library.New ideas or interesting examples are always welcome and can be submitted as an issue or a pull request on GitHub."
},

{
    "location": "index.html#Authors-1",
    "page": "Home",
    "title": "Authors",
    "category": "section",
    "text": "Ben Lauwens, Royal Military Academy, Brussels, Belgium"
},

{
    "location": "index.html#License-1",
    "page": "Home",
    "title": "License",
    "category": "section",
    "text": "SimJulia is licensed under the MIT \"Expat\" license."
},

{
    "location": "10_min/1_installation.html#",
    "page": "Installation",
    "title": "Installation",
    "category": "page",
    "text": ""
},

{
    "location": "10_min/1_installation.html#Installation-1",
    "page": "Installation",
    "title": "Installation",
    "category": "section",
    "text": "SimJulia is implemented in pure Julia and has no dependencies. SimJulia v0.4 runs on Julia v0.5.note: Note\nJulia can be run from the browser without setup: JuliaBox.The built-in package manager of Julia is used to install SimJulia:Pkg.add(\"SimJulia\")You can now optionally run SimJulia’s tests to see if everything is working fine:Pkg.test(\"SimJulia\")"
},

{
    "location": "10_min/2_basic_concepts.html#",
    "page": "Basic Concepts",
    "title": "Basic Concepts",
    "category": "page",
    "text": ""
},

{
    "location": "10_min/2_basic_concepts.html#Basic-Concepts-1",
    "page": "Basic Concepts",
    "title": "Basic Concepts",
    "category": "section",
    "text": "SimJulia is a discrete-event simulation library. The behavior of active components (like vehicles, customers or messages) is modeled with Processes. All processes live in an Environment, e.g. a Simulation. They interact with the environment and with each other via Events.Processes are described by simple Julia functions. During their lifetime, they create events and yield them in order to wait for them to be triggered.When a process yields an event, the process gets suspended. SimJulia resumes the process, when the event occurs (we say that the event is triggered). Multiple processes can wait for the same event. SimJulia resumes them in the same order in which they yielded that event.An important event is a timeout. Events of this type are triggered after a certain amount of (simulated) time has passed. They allow a process to sleep (or hold its state) for the given time. A timeout and all other events can be created by calling an appropriate function having a reference to the environment that the process lives in."
},

{
    "location": "10_min/2_basic_concepts.html#The-First-Process-1",
    "page": "Basic Concepts",
    "title": "The First Process",
    "category": "section",
    "text": "The first example will be a car process. The car will alternately drive and park for a while. When it starts driving (or parking), it will print the current simulation time.So let’s start:using SimJulia\n\nfunction car(sim::Simulation)\n  while true\n    println(\"Start parking at $(now(sim))\")\n    parking_duration = 5\n    yield(timeout(sim, parking_duration))\n    println(\"Start driving at $(now(sim))\")\n    trip_duration = 2\n    yield(timeout(sim, trip_duration))\n  end\nendThe car process function requires a reference to an Simulation in order to create new events. The car‘s behavior is described in an infinite loop. Though it will never terminate, it will pass the control flow back to the simulation once a yield statement is reached. If the yielded event is triggered (“it occurs”), the simulation will resume the function at this statement.The car switches between the states parking and driving. It announces its new state by printing a message and the current simulation time (as returned by the function now. It then calls the functions timeout to create a timeout event. This event describes the point in time the car is done parking (or driving, respectively). By yielding the event, it signals the simulation that it wants to wait for the event to occur.Now that the behavior of the car has been modeled, we create an instance of it and see how it behaves:using SimJulia\nfunction car(sim::Simulation)\n  while true\n    println(\"Start parking at $(now(sim))\")\n    parking_duration = 5\n    yield(timeout(sim, parking_duration))\n    println(\"Start driving at $(now(sim))\")\n    trip_duration = 2\n    yield(timeout(sim, trip_duration))\n  end\nendsim = Simulation()\nProcess(car, sim)\nrun(sim, 15)The first thing to do is to create an instance of class Simulation. This instance is passed into the car process function.Calling the constructor Process creates a process that is started immediately and is added to the environment. Note, that at this time, none of the code of our process function is being executed. Its execution is merely scheduled at the current simulation time.Finally, the simulation starts by calling run where the second argument is the end time."
},

{
    "location": "topics.html#",
    "page": "Manual",
    "title": "Manual",
    "category": "page",
    "text": ""
},

{
    "location": "examples/1_bank-renege.html#",
    "page": "-",
    "title": "-",
    "category": "page",
    "text": ""
},

{
    "location": "examples/1_bank-renege.html#Bank-Renege-1",
    "page": "-",
    "title": "Bank Renege",
    "category": "section",
    "text": "Covers:Resources\nEvent operatorsA counter with a random service time and customers who renege.This example models a bank counter and customers arriving at random times. Each customer has a certain patience. It waits to get to the counter until she’s at the end of her tether. If she gets to the counter, she uses it for a while.New customers are created by the source process every few time steps.using SimJulia\nusing Distributions\n\nconst RANDOM_SEED = 150\nconst NEW_CUSTOMERS = 5  # Total number of customers\nconst INTERVAL_CUSTOMERS = 10.0  # Generate new customers roughly every x seconds\nconst MIN_PATIENCE = 1.0  # Min. customer patience\nconst MAX_PATIENCE = 3.0  # Max. customer patience\n\nfunction source(sim::Simulation, number::Int, interval::Float64, counter::Resource)\n  d = Exponential(interval)\n  for i in 1:number\n    Process(customer, sim, \"Customer$i\", counter, 12.0)\n    yield(timeout(sim, rand(d)))\n  end\nend\n\nfunction customer(sim::Simulation, name::String, counter::Resource, time_in_bank::Float64)\n  arrive = now(sim)\n  println(\"$arrive $name: Here I am\")\n  request(counter) do req\n    patience = rand(Uniform(MIN_PATIENCE, MAX_PATIENCE))\n    result = yield(req | timeout(sim, patience))\n    wait = now(sim) - arrive\n    if state(result[req]) == SimJulia.processed\n      println(\"$(now(sim)) $name: Waited $wait\")\n      yield(timeout(sim, rand(Exponential(time_in_bank))))\n      println(\"$(now(sim)) $name: Finished\")\n    else\n      println(\"$(now(sim)) $name: RENEGED after $wait\")\n    end\n  end\nend\n\n# Setup and start the simulation\nprintln(\"Bank renege\")\nsrand(RANDOM_SEED)\nsim = Simulation()\n\n# Start processes and run\ncounter = Resource(sim, 1)\nProcess(source, sim, NEW_CUSTOMERS, INTERVAL_CUSTOMERS, counter)\nrun(sim)"
},

{
    "location": "api.html#",
    "page": "Library",
    "title": "Library",
    "category": "page",
    "text": ""
},

{
    "location": "api.html#API-1",
    "page": "Library",
    "title": "API",
    "category": "section",
    "text": ""
},

{
    "location": "api.html#SimJulia",
    "page": "Library",
    "title": "SimJulia",
    "category": "Module",
    "text": "SimJulia\n\nMain module for SimJulia.jl – a combined continuous time / discrete event process oriented simulation framework for Julia.\n\n\n\n"
},

{
    "location": "api.html#Public-1",
    "page": "Library",
    "title": "Public",
    "category": "section",
    "text": "Modules = [SimJulia]\nPages   = [\"SimJulia.jl\"]\nPrivate  = false"
},

{
    "location": "api.html#SimJulia.timeout-Tuple{E<:SimJulia.Environment,Base.Dates.Period}",
    "page": "Library",
    "title": "SimJulia.timeout",
    "category": "Method",
    "text": "Returns an event that gets triggered after a delay has passed.\n\nThis event is automatically scheduled when it is created.\n\nMethods:\n\ntimeout{E<:Environment}(env::E, delay::Period; priority::Bool=false, value::Any=nothing) :: Timeout{E}\ntimeout{E<:Environment}(env::E, delay::Number=0; priority::Bool=false, value::Any=nothing) :: Timeout{E}\n\n\n\n"
},

{
    "location": "api.html#Events-1",
    "page": "Library",
    "title": "Events",
    "category": "section",
    "text": "Modules = [SimJulia]\nPages   = [\"base.jl\", \"events.jl\", \"operators.jl\"]\nOrder   = [:type, :function]\nPrivate  = false"
},

{
    "location": "api.html#SimJulia.Simulation",
    "page": "Library",
    "title": "SimJulia.Simulation",
    "category": "Type",
    "text": "Execution environment for a simulation.\n\nThe passing of time is implemented by stepping from event to event.\n\nSignature: Simulation{T<:TimeType} <: Environment\n\nFields:\n\ntime :: T\nheap :: PriorityQueue{BaseEvent{Simulation{T}}, EventKey{T}}\neid :: UInt\nsid :: UInt\nactive_proc :: Nullable{Process}\n\nConstructors:\n\nSimulation{T<:TimeType}(initial_time::T) :: Simulation{T}\nSimulation(initial_time::Number=0) :: Simulation{SimulationTime}\n\nAn initial_time for the simulation can be specified. By default, it starts at 0.\n\n\n\n"
},

{
    "location": "api.html#Base.Dates.now-Tuple{SimJulia.Simulation{T<:Base.Dates.TimeType}}",
    "page": "Library",
    "title": "Base.Dates.now",
    "category": "Method",
    "text": "Returns the current simulation time.\n\nMethod: now{T<:TimeType}(sim::Simulation{T}) :: T\n\n\n\n"
},

{
    "location": "api.html#Base.run-Tuple{SimJulia.Simulation,SimJulia.AbstractEvent}",
    "page": "Library",
    "title": "Base.run",
    "category": "Method",
    "text": "Executes step until the given criterion is met:\n\nif nothing is not specified, the method will return when there are no further events to be processed\nif it is a subtype of AbstractEvent, the simulation will continue stepping until this event has been triggered and will return its value\nif it is a subtype of TimeType, the simulation will continue stepping until the simulation’s time reaches until\nif it is a subtype of Period, the simulation will continue stepping during the given period\nif it is a subtype of Number, the method will continue stepping during a period of elementary time units\n\nIn the first two cases, the simulation can prematurely stop when there are no further events to be processed.\n\nIf the stepping end with a StopSimulation exception the function return the value of the exception, in all other cases the exception is rethrown.\n\nMethods:\n\nrun(sim::Simulation, until::AbstractEvent) :: Any\nrun{T<:TimeType}(sim::Simulation{T}, until::T) :: Any\nrun(sim::Simulation, period::Union{Period, Number}) :: Any\nrun(sim::Simulation) :: Any\n\n\n\n"
},

{
    "location": "api.html#Simulation-1",
    "page": "Library",
    "title": "Simulation",
    "category": "section",
    "text": "Modules = [SimJulia]\nPages   = [\"simulation.jl\"]\nOrder   = [:type, :function]\nPrivate  = false"
},

{
    "location": "api.html#SimJulia.Process",
    "page": "Library",
    "title": "SimJulia.Process",
    "category": "Type",
    "text": "A Process is an abstraction for an event yielding function, i.e. a process function.\n\nThe process function can suspend its execution by yielding an instance of AbstractEvent. The Environment will take care of resuming the process function with the value of that event once it has happened. The exception of failed events is also thrown into the process function.\n\nA Process is a subtype of AbstractEvent. It is triggered, once the process functions returns or raises an exception. The value of the process is the return value of the process function or the exception, respectively.\n\nSignature:\n\nProcess{E<:Environment} <: AbstractEvent{E}\n\nFields:\n\nbev :: BaseEvent{E}\ntask :: Task\ntarget :: AbstractEvent{E}\nresume :: Function\n\nConstructor:\n\nProcess{E<:Environment}(func::Function, env::E, args::Any...) :: Process{E}\n\n\n\n"
},

{
    "location": "api.html#Base.yield-Tuple{SimJulia.AbstractEvent}",
    "page": "Library",
    "title": "Base.yield",
    "category": "Method",
    "text": "Passes the control flow back to the simulation. If the yielded event is triggered, the Environment will resume the function after this statement.\n\nThe return value is the value from the yielded event.\n\nMethod:\n\nyield(target::AbstractEvent) :: Any\n\n\n\n"
},

{
    "location": "api.html#Processes-1",
    "page": "Library",
    "title": "Processes",
    "category": "section",
    "text": "Modules = [SimJulia]\nPages   = [\"process.jl\"]\nOrder   = [:type, :function]\nPrivate  = false"
},

{
    "location": "api.html#Internals-1",
    "page": "Library",
    "title": "Internals",
    "category": "section",
    "text": ""
},

{
    "location": "api.html#SimJulia.step-Tuple{SimJulia.Simulation}",
    "page": "Library",
    "title": "SimJulia.step",
    "category": "Method",
    "text": "Does a simulation step and processes the next event.\n\nMethod:\n\nstep(sim::Simulation) :: Bool\n\n\n\n"
},

{
    "location": "api.html#Simulation-2",
    "page": "Library",
    "title": "Simulation",
    "category": "section",
    "text": "Modules = [SimJulia]\nPages   = [\"simulation.jl\"]\nOrder   = [:type, :function]\nPublic  = false"
},

]}

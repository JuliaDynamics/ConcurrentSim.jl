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
    "text": "SimJulia is a combined continuous time / discrete event process oriented simulation framework written in Julia inspired by the Simula library DISCO and the Python library SimPy."
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
    "location": "index.html#Installation-1",
    "page": "Home",
    "title": "Installation",
    "category": "section",
    "text": "SimJulia.jl is a registered package, and is simply installed by runningjulia> Pkg.add(\"SimJulia\")"
},

{
    "location": "intro.html#",
    "page": "Intro",
    "title": "Intro",
    "category": "page",
    "text": ""
},

{
    "location": "topics.html#",
    "page": "Manual",
    "title": "Manual",
    "category": "page",
    "text": ""
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
    "location": "api.html#SimJulia.Event",
    "page": "Library",
    "title": "SimJulia.Event",
    "category": "Type",
    "text": "Event\n\nAn event is a state machine with three states:\n\nidle\ntriggered\nprocessed\n\nAn event is initially not triggered. Events get trigerred after they are scheduled for processing.\n\nAn event has a list of callbacks and a value. A callback can be any function. Once an event gets processed, all callbacks will be invoked. Callbacks can do further processing with the value it has produced.\n\nFailed events, i.e. events having as value an Exception, are never silently ignored and will raise this exception upon being processed.\n\nFields:\n\ncid :: UInt\ncallbacks :: PriorityQueue{Function, UInt}\nstate :: EVENT_STATE\nvalue :: Any\n\nConstructor:\n\nEvent()\n\n\n\n"
},

{
    "location": "api.html#SimJulia.Simulation",
    "page": "Library",
    "title": "SimJulia.Simulation",
    "category": "Type",
    "text": "Simulation{T<:TimeType}\n\nExecution environment for a simulation. The passing of time is implemented by stepping from event to event.\n\nFields:\n\ntime :: T\nheap :: PriorityQueue{Event, EventKey}\nsid :: UInt\nactive_proc :: Nullable{Process}\ngranularity :: Type\n\nConstructor:\n\nSimulation{T<:TimeType}(initial_time::T) Simulation(initial_time::Number=0)\n\nAn initial_time for the simulation can be specified. By default, it starts at 0.\n\n\n\n"
},

{
    "location": "api.html#SimJulia.append_callback-Tuple{SimJulia.Event,Function,Vararg{Any,N}}",
    "page": "Library",
    "title": "SimJulia.append_callback",
    "category": "Method",
    "text": "append_callback(ev::Event, cb::Function, args...) :: Function\n\nAdds a callback function to an event, i.e. a function having as first argument an object of type Simulation and as second argument the event. Optional arguments can be specified by args....\n\nIf the event is being processed an EventProcessing exception is thrown.\n\n\n\n"
},

{
    "location": "api.html#SimJulia.value-Tuple{SimJulia.Event}",
    "page": "Library",
    "title": "SimJulia.value",
    "category": "Method",
    "text": "value(ev::Event) :: Any\n\nReturns the value of the event.\n\n\n\n"
},

{
    "location": "api.html#Base.Dates.now-Tuple{SimJulia.Simulation}",
    "page": "Library",
    "title": "Base.Dates.now",
    "category": "Method",
    "text": "now(sim::Simulation) :: TimeType\n\nReturns the current simulation time.\n\n\n\n"
},

{
    "location": "api.html#Base.run-Tuple{SimJulia.Simulation,SimJulia.Event}",
    "page": "Library",
    "title": "Base.run",
    "category": "Method",
    "text": "run(sim::Simulation, until::Event)\nrun(sim::Simulation, until::TimeType)\nrun(sim::Simulation, period::Period)\nrun(sim::Simulation, period::Number)\nrun(sim::Simulation)\n\nExecutes step until the given criterion until is met:\n\nif it is not specified, the method will return when there are no further events to be processed\nif it is an Event, the method will continue stepping until this event has been triggered and will return its value\nif it is a TimeType, the method will continue stepping until the simulation’s time reaches until\nif it is a Period, the method will continue stepping until the simulation’s time has passed until periods\nif it is a Number, the method will continue stepping until the simulation’s time has passed until elementary periods\n\nIn the last two cases, the simulation can prematurely stop when there are no further events to be processed.\n\n\n\n"
},

{
    "location": "api.html#Base.schedule-Tuple{SimJulia.Simulation,SimJulia.Event,Base.Dates.Period}",
    "page": "Library",
    "title": "Base.schedule",
    "category": "Method",
    "text": "schedule(sim::Simulation, ev::Event, delay::Period; priority::Bool=false, value::Any=nothing) :: Event\nschedule(sim::Simulation, ev::Event, delay::Number=0; priority::Bool=false, value::Any=nothing) :: Event\n\nSchedules an event at time sim.time + delay with a priority and a value.\n\nIf the event is already scheduled or is being processed, an EventNotIdle exception is thrown.\n\n\n\n"
},

{
    "location": "api.html#SimJulia.schedule!-Tuple{SimJulia.Simulation,SimJulia.Event,Base.Dates.Period}",
    "page": "Library",
    "title": "SimJulia.schedule!",
    "category": "Method",
    "text": "schedule!(sim::Simulation, ev::Event, delay::Period; priority::Bool=false, value::Any=nothing) :: Event\nschedule!(sim::Simulation, ev::Event, delay::Number=0; priority::Bool=false, value::Any=nothing) :: Event\n\nSchedules an event at time sim.time + delay with a priority and a value.\n\nIf the event is already scheduled, the key is updated with the new delay and priority. The new value is also set.\n\nIf the event is being processed, an EventProcessing exception is thrown.\n\n\n\n"
},

{
    "location": "api.html#Base-1",
    "page": "Library",
    "title": "Base",
    "category": "section",
    "text": "Modules = [SimJulia]\nPages   = [\"types.jl\", \"events.jl\", \"simulation.jl\", \"exceptions.jl\"]\nPrivate  = false"
},

{
    "location": "api.html#Processes-1",
    "page": "Library",
    "title": "Processes",
    "category": "section",
    "text": "Modules = [SimJulia]\nPages   = [\"process.jl\"]\nPrivate  = false"
},

{
    "location": "api.html#Continuous-1",
    "page": "Library",
    "title": "Continuous",
    "category": "section",
    "text": ""
},

{
    "location": "api.html#Resources-1",
    "page": "Library",
    "title": "Resources",
    "category": "section",
    "text": "Modules = [SimJulia]\nPages   = [\"resources/base.jl\", \"resources/containers.jl\", \"resources/stores.jl\"]\nPrivate  = false"
},

{
    "location": "api.html#SimJulia.EVENT_STATE",
    "page": "Library",
    "title": "SimJulia.EVENT_STATE",
    "category": "Type",
    "text": "EVENT_STATE\n\nEnum with values:\n\nidle=0\ntriggered=1\nprocessed=2\n\n\n\n"
},

{
    "location": "api.html#SimJulia.EventKey",
    "page": "Library",
    "title": "SimJulia.EventKey",
    "category": "Type",
    "text": "EventKey\n\nKey for the event heap.\n\nFields:\n\ntime :: Float64\npriority :: Bool\nid :: UInt\n\nConstructor:\n\nEventKey(time :: Float64, priority :: Bool, id :: UInt)\n\nOnly used internally.\n\n\n\n"
},

{
    "location": "api.html#Base.isless-Tuple{SimJulia.EventKey,SimJulia.EventKey}",
    "page": "Library",
    "title": "Base.isless",
    "category": "Method",
    "text": "isless(a::EventKey, b::EventKey) :: Bool\n\nCompairs two EventKey. The criteria in order of importance are:\n\ntime of processing\npriority when time of processing is equal\nscheduling id, i.e. the event that was first scheduled is first processed when time of processing and priority are identical\n\nOnly used internally.\n\n\n\n"
},

{
    "location": "api.html#Internals-1",
    "page": "Library",
    "title": "Internals",
    "category": "section",
    "text": "Modules = [SimJulia]\nPages   = [\"SimJulia.jl\", \"types.jl\"]\nPublic  = false"
},

]}

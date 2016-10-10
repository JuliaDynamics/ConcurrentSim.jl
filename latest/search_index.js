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
    "text": "SimJulia is a combined continuous time / discrete event process oriented simulation framework written in Julia inspired by the Simula library DISCO and the Python library SimPy.Its event dispatcher is based on a Task. This is a control flow feature in Julia that allows computations to be suspended and resumed in a flexible manner. Processes in SimJulia are defined by functions yielding Events. SimJulia also provides three types of shared resources to model limited capacity congestion points: Resources, Containers and Stores. The API is modeled after the SimPy API but using some specific Julia semantics.The continuous time simulation framework is still under development and is based on a quantized state system solver that naturally integrates in the discrete event framework. Events can be triggered on Zerocrossings of functions depending on the continuous Variables.SimJulia contains tutorials, in-depth documentation, and a large number of examples. Most of the tutorials and the examples are borrowed from the SimPy distribution to allow a direct comparison and an easy migration path for users. The examples of continuous time simulation are heavily influenced by the examples in the DISCO library.New ideas or interesting examples are always welcome and can be submitted as an issue or a pull request on GitHub."
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
    "location": "10_min/installation.html#",
    "page": "-",
    "title": "-",
    "category": "page",
    "text": ""
},

{
    "location": "10_min/installation.html#Installation-1",
    "page": "-",
    "title": "Installation",
    "category": "section",
    "text": "SimJulia is implemented in pure Julia and has no dependencies. SimJulia runs on Julia v0.5... note::    Julia can be run from the browser without setup: JuliaBox <https://www.juliabox.com/>_The built-in package manager of Julia is used to install SimJulia::julia> Pkg.add(\"SimJulia\")You can now optionally run SimJulia’s tests to see if everything is working fine::julia> Pkg.test(\"SimJulia\")   ...   INFO: SimJulia tests passed   ..."
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
    "location": "api.html#Base-1",
    "page": "Library",
    "title": "Base",
    "category": "section",
    "text": "Modules = [SimJulia]\nPages   = [\"base.jl\"]\nPrivate  = false"
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
    "location": "api.html#Internals-1",
    "page": "Library",
    "title": "Internals",
    "category": "section",
    "text": "Modules = [SimJulia]\nPages   = [\"SimJulia.jl\", \"base.jl\"]\nPublic  = false"
},

]}

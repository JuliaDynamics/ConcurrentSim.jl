Installation
------------

SimJulia is implemented in pure Julia and has no dependencies. SimJulia runs on Julia v0.3  and Julia v0.4.

The built-in package manager of Julia is used to install SimJulia::

  julia> Pkg.add("SimJulia")

You can now optionally run SimJulia’s tests to see if everything works fine::

  julia> Pkg.test("SimJulia")

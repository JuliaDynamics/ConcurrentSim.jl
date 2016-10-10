Installation
------------

SimJulia is implemented in pure Julia and has no dependencies. SimJulia runs on Julia v0.5.

.. note::
   Julia can be run from the browser without setup: [JuliaBox](https://www.juliabox.com/).

The built-in package manager of Julia is used to install SimJulia::

```@repl
Pkg.add("SimJulia")
```

You can now optionally run SimJulia’s tests to see if everything is working fine::

```@repl
Pkg.test("SimJulia")
```

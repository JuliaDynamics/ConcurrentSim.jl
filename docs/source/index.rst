.. SimJulia documentation master file, created by
   sphinx-quickstart on Thu Aug  6 13:27:36 2015.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to SimJulia!
====================

**SimJulia** is a combined continuous time / discrete event process oriented simulation framework written in [Julia](http://julialang.org) inspired by the Simula library **DISCO** and the Python library [**SimPy**](http://simpy.sourceforge.net/).

It's event dispatcher is based on a **Task**. This is a control flow feature in julia that allows computations to be suspended and resumed in a flexible manner. **Processes** in SimJulia are defined by functions producing **events**. SimJulia also provides two types of shared resources to model limited capacity congestion points: **resources** and **containers**. The former models a discrete congestion point, the latter a continuous congestion point. The API is modeled after the SimPy API but using some Julia specific semantics.

The continuous time simulation is still under development and will be based on a quantized state system solver that naturally integrates in the discrete event framework.

SimJulia contains tutorials, in-depth documentation, and a large number of examples. The tutorals and the examples are borrowed from the SimPy distribution to allow a direct comparison and an easy migration path for users.

SimPy is released under the MIT License.

Contents:

.. toctree::
   :maxdepth: 2

10_min


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`


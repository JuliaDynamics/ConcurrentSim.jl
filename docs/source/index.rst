********************
Welcome to SimJulia!
********************

**SimJulia** is a combined continuous time / discrete event process oriented simulation framework written in `Julia <http://julialang.org>`_ inspired by the Simula library **DISCO** and the Python library `SimPy <http://simpy.sourceforge.net/>`_.

It's event dispatcher is based on a :type:`Task`. This is a control flow feature in Julia that allows computations to be suspended and resumed in a flexible manner. `Processes` in SimJulia are defined by functions yielding `Events`. SimJulia also provides two types of shared resources to model limited capacity congestion points: `Resources` and `Containers`. The former models a discrete congestion point, the latter a continuous congestion point. The API is modeled after the SimPy API but using some Julia specific semantics.

The continuous time simulation is still under development and will be based on a quantized state system solver that naturally integrates in the discrete event framework.

SimJulia contains tutorials, in-depth documentation, and a large number of examples. The tutorals and the examples are borrowed from the SimPy distribution to allow a direct comparison and an easy migration path for users.

SimJulia is released under the MIT License.


Contents
========

.. toctree::
   :maxdepth: 2

   10_min/index


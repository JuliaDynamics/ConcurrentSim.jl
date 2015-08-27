Resources
---------

SimJulia implements three types of resources that can be used to synchronize processes or to model congestion points:

  - :class:`Resource`: shared resources supporting priorities and preemption.
  - :class:`Container`: resource for sharing homogeneous matter between processes, either continuous or discrete.
  - :class:`Store`: shared resources for storing a possibly unlimited amount of objects supporting requests for specific objects.

They are derived from the abstract type :class:`AbstractResource`. Common functions to all types of resources can be found in `resources\base.jl`. These are also meant to support the implementation of custom resource types.


AbstractResource
~~~~~~~~~~~~~~~~

.. type:: abstract AbstractResource

.. function:: capacity(res::AbstractResource)

Returns the ``capacity`` of the resource.

Resource
~~~~~~~~

.. type:: Resource



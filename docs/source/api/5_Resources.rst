Resources
---------

SimJulia implements three types of resources that can be used to synchronize processes or to model congestion points:

  - :class:`Resource`: shared resources supporting priorities and preemption.
  - :class:`Container`: resource for sharing homogeneous matter between processes, either continuous or discrete.
  - :class:`Store`: shared resources for storing a possibly unlimited amount of objects supporting requests for specific objects.


AbstractResource
~~~~~~~~~~~~~~~~

.. type:: abstract AbstractResource

All resource types are derived from the abstract type :class:`AbstractResource`. Common functions to all types of resources can be found in `resources\\base.jl`. These are also meant to support the implementation of custom resource types.

.. function:: capacity(res::AbstractResource)

Returns the ``capacity`` of the resource.


ResourceEvent
~~~~~~~~~~~~~

.. type:: abstract ResourceEvent <: AbstractEvent

All events related to resources are derived from the abstract type :class:`ResourceEvent`.

.. type:: abstract PutEvent <: ResourceEvent

Abstract event for requesting to put something into the resource.

.. function:: cancel(ev::PutEvent)

Cancel the put request ``ev``.

This method has to be called if the put request must be aborted, for example if a process needs to handle an exception like an :class:`Interruption`.

.. type:: abstract GetEvent <: ResourceEvent

Generic event for requesting to get something from the resource.

.. function:: cancel(ev::GetEvent)

Cancel this get request ``ev``.

This method has to be called if the get request must be aborted, for example if a process needs to handle an exception like an :class:`Interruption`.


Resource
~~~~~~~~

.. type:: Resource <: AbstractResource

Shared resources supporting priorities and preemption.

These resources can be used to limit the number of processes using them concurrently. A process needs to `request` the usage right to a resource. Once the usage right is not needed anymore it has to be `released`. A gas station can be modelled as a resource with a limited amount of fuel-pumps. Vehicles arrive at the gas station and request to use a fuel-pump. If all fuel-pumps are in use, the vehicle needs to wait until one of the users has finished refueling and releases its fuel-pump.

These resources can be used by a limited number of processes at a time. Processes request these resources to become a `user` and have to release them once they are done. For example, a gas station with a limited number of fuel pumps can be modeled with a Resource. Arriving vehicles request a fuel-pump. Once one is available they refuel. When they are done, the release the fuel-pump and leave the gas station.

Requesting a resource is modelled as "putting a process’ token into the resources” and releasing a resources correspondingly as “getting a process’ token out of the resource”. Note, that releasing a resource will always succeed immediately, no matter if a process is actually using a resource or not.

.. function:: Resource(env::AbstractEnvironment, capacity::Int=1) -> Resource

Resource with ``capacity`` of usage slots that can be requested by processes.
If all slots are taken, requests are enqueued. Once a usage request is released, a pending request will be triggered.
The ``env`` argument is the :class:`AbstractEnvironment` instance the resource is bound to.

.. function:: count(res::Resource) -> Int

Returns the number of users currently using ``res``.

ResourcePut
~~~~~~~~~~~

.. type:: ResourcePut <: PutEvent

Subtype of :class:`PutEvent` for requesting to put something in a :class:`Resource`.

.. function:: Put(res::Resource, priority::Int=0, preempt::Bool=false) -> ResourcePut

.. function:: Request(res::Resource, priority::Int=0, preempt::Bool=false) -> ResourcePut

Request usage of the :class:`Resource` with a given ``priority``. The event is triggered once access is granted.

If the maximum capacity of users has not yet been reached, the request is triggered immediately. If the maximum capacity has been reached, the request is triggered once an earlier usage request on the resource is released. If ``preempt`` is ``true`` other usage requests of the resource may be preempted.


ResourceGet
~~~~~~~~~~~

.. type:: ResourceGet <: GetEvent

Subtype of :class:`GetEvent` for requesting to get something from a :class:`Resource`.

.. function:: Get(res::Resource) -> ResourceGet

.. function:: Release(res::Resource) -> ResourceGet

Releases the usage of ``resource`` by the active process. This event is triggered immediately.


Preempted
~~~~~~~~~

.. type:: Preempted

Cause of a preemption :class:`Interruption` containing information about the preemption.

.. function:: by(pre::Preempted) -> Process

Returns the preempting :class:`Process`.

.. function:: usage_since(pre::Preempted) -> Float64

Returns the simulation time at which the preempted process started to use the resource.


Container
~~~~~~~~~

.. type:: Container{T<:Number} <: AbstractResource

Resource for sharing homogeneous matter between processes, either continuous (like water) or discrete (like apples).

A :class:`Container` can be used to model the fuel tank of a gasoline station. Tankers increase and refuelled cars decrease the amount of gas in the station’s fuel tanks.

.. function:: Container{T}(env::Environment, capacity::T=typemax(T), level::T=zero(T)) -> Container{T}

Resource containing up to capacity of matter which may either be continuous (like water) or discrete (like apples). It supports requests to put or get matter into/from the container.

The ``env`` argument is the :class:`AbstractEnvironment` instance the container is bound to.

The ``capacity`` defines the size of the container.The initial amount of matter is specified by ``level`` and defaults to ``zero(T)``.

.. function:: level(cont::Container) -> T

Returns the current amount of the matter in the container.


ContainerPut
~~~~~~~~~~~~

.. type:: ContainerPut <: PutEvent

Subtype of :class:`PutEvent` for requesting to put something in a :class:`Container`.

.. function:: Put{T<:Number}(cont::Container{T}, amount::T, priority::Int=0) -> ContainerPut

Request to put ``amount`` of matter into the container with a given ``priority``. The request will be triggered once there is enough space in the container available.


ContainerGet
~~~~~~~~~~~~

.. type:: ContainerGet <: GetEvent

Subtype of :class:`GetEvent` for requesting to get something from a :class:`Container`.

.. function:: Get{T<:Number}(cont::Container{T}, amount::T, priority::Int=0) -> ContainerGet

Request to get ``amount`` of matter from the container with a given ``priority``. The request will be triggered once there is enough matter available in the container.


Store
~~~~~

.. type:: Store{T} <: AbstractResource

Shared resources for storing a possibly unlimited amount of objects supporting requests for specific objects.

The :class:`Store` operates in a FIFO (first-in, first-out) order. Objects are retrieved from the store in the order they were put in. The get requests can be customized by a filter to only retrieve objects matching a given criterion.

.. function:: Store{T}(env::Environment, capacity::Int=typemax(Int)) -> Store{T}

Resource with capacity slots for storing arbitrary objects. By default, the capacity is unlimited and objects are put and retrieved from the store in a first-in first-out order.

The env argument is the :class:`AbstractEnvironment` instance the store is bound to.

StorePut
~~~~~~~~

.. type:: StorePut{T} <: PutEvent

Subtype of :class:`PutEvent` for requesting to put something in a :class:`Store`.

.. function:: Put{T}(sto::Store{T}, item::T, priority::Int=0) -> StorePut

Request to put ``item`` into the store with a given ``priority``. The request is triggered once there is space for the item in the store.


StoreGet
~~~~~~~~

.. type:: StoreGet <: GetEvent

Subtype of :class:`GetEvent` for requesting to get something from a :class:`Store`.

.. function:: Get{T}(sto::Store{T}, filter::Function=(item::T)->true, priority::Int=0)

Request to get an item from the store matching the ``filter`` with a ``priority``. The request is triggered once there is such an item available in the store.

``filter`` is a function receiving one item. It should return ``true`` for items matching the filter criterion. The default function returns ``true`` for all items

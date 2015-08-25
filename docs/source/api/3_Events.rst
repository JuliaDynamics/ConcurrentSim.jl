Events
------

AbstractEvent
~~~~~~~~~~~~~

.. type:: AbstractEvent

The parent type for all events is :class:`AbstractEvent`.

.. function:: triggered(ev::AbstractEvent) -> is_triggered::Bool

Returns ``true`` if the event has been triggered and its callbacks are about to be invoked.

.. function:: processed(ev::AbstractEvent) -> is_processed::Bool

Returns ``true`` if the event has been processed (i.e., its callbacks have been invoked).

.. function:: value(ev::AbstractEvent) -> value::Any

Returns the ``value`` of the event if it is available, otherwise returns ``nothing``. The value is available when the event has been triggered.

.. function:: append_callback(ev::AbstractEvent, callback::Function, args...)

Adds a process function to the event. The first argument of the function ``callback`` is an :class:`AbstractEnvironment`. Optional arguments can be specified by ``args...``. If the event is already processed an :class:`EventProcessed` exception is thrown.

.. function:: succeed(ev::AbstractEvent, value=nothing) -> ev::AbstractEvent

Sets the event’s `value` and schedule it for processing by the environment. Returns the event instance. Throws an :class:`EventTriggered` exception if this event has already been triggered.

.. function:: fail(ev::AbstractEvent, exc::Exception) -> ev::AbstractEvent

Sets the exception as the events value, mark it as failed and schedule it for processing by the environment. Returns the event instance. Throws an :class:`EventTriggered` exception if this event has already been triggered.

.. function:: trigger(cause::AbstractEvent, ev::AbstractEvent) -> ev::AbstractEvent

Schedules the event with the state and value of the `cause` event. Returns the event instance. Throws an :class:`EventTriggered` exception if this event has already been triggered.
This method can be used directly as a callback function to trigger chain reactions.


Event
~~~~~

.. type:: Event <: AbstractEvent

An event that may happen at some point in time.

An event:

- may happen (``triggered`` returns ``false``),
- is going to happen (``triggered`` returns ``true``),
- is happening (``processed`` returns ``false``) or
- has happened (``processed`` returns ``true``).

Every event is bound to an environment and is initially not triggered. Events are scheduled for processing by the environment after they are triggered by either ``succeed``, ``fail`` or ``trigger``. These methods also set the value of the event.

An event has a list of callbacks. A callback can be any function as long as it accepts an instance of type :class:`Event` as its first argument. Once an event gets processed, all callbacks will be invoked. Callbacks can do further processing with the value it has produced.

Failed events are never silently ignored and will raise an exception upon being processed.

.. function:: Event(env::AbstractEnvironment) -> ev::Event

Constructor of :class:`Event` with one argument ``env``, the environment where the event lives in.


